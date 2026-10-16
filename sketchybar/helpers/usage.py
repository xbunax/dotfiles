#!/usr/bin/env python3
"""Read-only Codex OAuth usage. stdout is sanitized JSON; never print credentials.

Reference: https://github.com/steipete/CodexBar/blob/main/docs/codex.md
No token renewal, browser access, or writes to CODEX_HOME. Images are the only cache.
"""

import base64
import hashlib
import json
import math
import os
import struct
import sys
import tempfile
import time
import urllib.error
import urllib.request
import zlib
from pathlib import Path

ENDPOINT = "https://chatgpt.com/backend-api/wham/usage"
MAX_RESPONSE = 1024 * 1024


class UsageError(Exception):
    def __init__(self, code, retry_after=None):
        self.code = code
        self.retry_after = retry_after


def object_or_empty(value):
    return value if isinstance(value, dict) else {}


def claims(token):
    if not isinstance(token, str):
        return {}
    try:
        part = token.split(".")[1]
        return object_or_empty(json.loads(base64.urlsafe_b64decode(part + "=" * (-len(part) % 4))))
    except (ValueError, IndexError, TypeError):
        return {}


def number(value):
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return None
    return value if math.isfinite(value) else None


def read_auth(home):
    # A CLI can atomically publish/replace this file; allow one brief reread.
    auth = {}
    for attempt in range(2):
        try:
            with (home / "auth.json").open() as stream:
                auth = object_or_empty(json.load(stream))
            break
        except (OSError, ValueError):
            if attempt:
                raise UsageError("auth_missing") from None
            time.sleep(0.05)
    if auth.get("auth_mode") == "apikey":
        raise UsageError("auth_missing")
    tokens = object_or_empty(auth.get("tokens"))
    token = tokens.get("access_token")
    if not isinstance(token, str) or not token or any(c.isspace() for c in token):
        raise UsageError("auth_missing")
    account = tokens.get("account_id")
    if account is not None and (not isinstance(account, str) or not account or any(c.isspace() for c in account)):
        raise UsageError("auth_invalid")
    payload = claims(token)
    id_payload = claims(tokens.get("id_token", ""))
    subject = account or id_payload.get("sub") or payload.get("sub") or token
    identity = hashlib.sha256(str(subject).encode()).hexdigest()
    fingerprint = hashlib.sha256(token.encode()).hexdigest()
    expiry = number(payload.get("exp"))
    return token, account, identity, fingerprint, expiry


def window(raw):
    if not isinstance(raw, dict):
        return None
    used = number(raw.get("used_percent"))
    seconds = number(raw.get("limit_window_seconds"))
    reset = number(raw.get("reset_at"))
    # Invalid values are unavailable, never inferred as unused or exhausted.
    if used is None or not 0 <= used <= 100 or seconds is None or seconds <= 0:
        return None
    if reset is None:
        delay = number(raw.get("reset_after_seconds"))
        reset = int(time.time() + delay) if delay is not None and delay >= 0 else None
    return {"remaining": round(100 - used, 2), "seconds": seconds,
            "reset_at": reset if reset is not None and reset > 0 else None}


def normalize(raw):
    if not isinstance(raw, dict):
        raise UsageError("invalid_response")
    limits = object_or_empty(raw.get("rate_limit"))
    primary = window(limits.get("primary_window"))
    secondary = window(limits.get("secondary_window"))
    if not primary and not secondary:
        raise UsageError("no_windows")
    plan = raw.get("plan_type")
    if not isinstance(plan, str) or len(plan) > 60 or not all(c.isalnum() or c in " _-+." for c in plan):
        plan = "未知套餐"
    return {"plan": plan, "primary": primary, "secondary": secondary}


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        # Never forward an OAuth Authorization header to another host.
        return None


def fetch(token, account):
    headers = {"Authorization": "Bearer " + token, "Accept": "application/json",
               "User-Agent": "sketchybar-codex-usage/1.0"}
    if account:
        headers["ChatGPT-Account-Id"] = account
    request = urllib.request.Request(ENDPOINT, headers=headers)
    try:
        with urllib.request.build_opener(NoRedirect()).open(request, timeout=12) as response:
            data = response.read(MAX_RESPONSE + 1)
        if len(data) > MAX_RESPONSE:
            raise UsageError("invalid_response")
        return normalize(json.loads(data))
    except urllib.error.HTTPError as exc:
        exc.close()
        if exc.code in (401, 403):
            raise UsageError("auth_expired") from None
        if exc.code == 429:
            retry = exc.headers.get("Retry-After", "")
            retry = int(retry) if retry.isdigit() and len(retry) < 10 else 300
            raise UsageError("rate_limited", max(60, min(retry, 3600))) from None
        raise UsageError("server_error") from None
    except (urllib.error.URLError, TimeoutError, OSError):
        raise UsageError("network_error") from None
    except (ValueError, UnicodeError):
        raise UsageError("invalid_response") from None


def collect(home=None):
    home = Path(home) if home is not None else Path(os.environ.get("CODEX_HOME") or Path.home() / ".codex")
    identity = None
    fingerprint = None
    try:
        token, account, identity, fingerprint, expiry = read_auth(home)
        if expiry is not None and expiry <= time.time() + 30:
            raise UsageError("auth_expired")
        result = fetch(token, account)
        # Do not publish a response for credentials replaced during the request.
        current = read_auth(home)
        if current[2] != identity or current[3] != fingerprint:
            raise UsageError("auth_changed")
        return dict(result, ok=True, identity=identity, updated_at=int(time.time()))
    except UsageError as exc:
        if identity is not None and exc.code in {"network_error", "server_error", "rate_limited", "invalid_response"}:
            try:
                current = read_auth(home)
                if current[2] != identity or current[3] != fingerprint:
                    exc = UsageError("auth_changed")
            except UsageError as auth_error:
                exc = auth_error
        return {"ok": False, "error": exc.code, "identity": identity,
                "retry_after": exc.retry_after}


DEFAULT_PALETTE = {"white": 0xffffffff, "grey": 0xffaeaeb2, "orange": 0xffff9f0a,
                   "red": 0xffff453a, "blue": 0xff0a84ff, "track": 0x38ffffff}


def rgba(argb):
    return ((argb >> 16) & 255, (argb >> 8) & 255, argb & 255, (argb >> 24) & 255)


def paint_rect(pixels, width, height, box, color, radius=0):
    left, top, right, bottom = box
    radius = min(radius, (right - left) / 2, (bottom - top) / 2)
    for y in range(max(0, int(top)), min(height, math.ceil(bottom))):
        for x in range(max(0, int(left)), min(width, math.ceil(right))):
            cx = min(max(x + 0.5, left + radius), right - radius)
            cy = min(max(y + 0.5, top + radius), bottom - radius)
            if (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2 <= radius ** 2:
                start = (y * width + x) * 4
                pixels[start:start + 4] = bytes(color)


def png(width, height, pixels):
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    rows = b"".join(b"\x00" + pixels[y * width * 4:(y + 1) * width * 4] for y in range(height))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(rows)) + chunk(b"IEND", b""))


def quota_color(remaining, palette, icon=False, stale=False):
    if remaining is None or stale:
        return rgba(palette["grey"])
    key = "red" if remaining <= 10 else "orange" if remaining <= 20 else "white" if icon else "blue"
    return rgba(palette[key])


def icon_png(primary, secondary, palette, stale=False, error=False):
    pixels = bytearray(36 * 36 * 4)
    for remaining, y in ((primary, 7), (secondary, 22)):
        paint_rect(pixels, 36, 36, (2, y, 34, y + 7), rgba(palette["track"]), 3)
        if remaining is not None and remaining > 0:
            paint_rect(pixels, 36, 36, (2, y, 2 + max(1, 32 * remaining / 100), y + 7),
                       quota_color(remaining, palette, icon=True, stale=stale), 3)
    if error or stale:
        paint_rect(pixels, 36, 36, (30, 4, 34, 14), rgba(palette["orange"]), 1)
        paint_rect(pixels, 36, 36, (30, 16, 34, 19), rgba(palette["orange"]), 1)
    return png(36, 36, pixels)


def bar_png(remaining, palette, stale=False):
    pixels = bytearray(512 * 12 * 4)
    paint_rect(pixels, 512, 12, (0, 0, 512, 12), rgba(palette["track"]), 6)
    if remaining is not None and remaining > 0:
        paint_rect(pixels, 512, 12, (0, 0, max(2, 512 * remaining / 100), 12),
                   quota_color(remaining, palette, stale=stale), 6)
    return png(512, 12, pixels)


def render_assets(result, palette=None, directory=None):
    palette = palette or DEFAULT_PALETTE
    directory = Path(directory) if directory is not None else Path.home() / "Library/Caches/sketchybar-usage"
    if directory.is_symlink():
        raise OSError("Unsafe cache directory")
    directory.mkdir(mode=0o700, parents=True, exist_ok=True)
    directory.chmod(0o700)

    def save(data):
        target = directory / (hashlib.sha256(data).hexdigest()[:24] + ".png")
        if not target.exists():
            with tempfile.NamedTemporaryFile(dir=directory, delete=False) as stream:
                temporary = Path(stream.name)
                stream.write(data)
            try:
                temporary.replace(target)
            finally:
                temporary.unlink(missing_ok=True)
        os.utime(target, None)
        return str(target)

    values = [object_or_empty(result.get(key)).get("remaining") for key in ("primary", "secondary")]
    lanes = [object_or_empty(result.get(key)) for key in ("primary", "secondary")]
    weekly = next((lane for lane in lanes if lane.get("seconds") == 604800), None)
    icon_values = values
    if weekly is not None:
        short = next((lane for lane in lanes if lane and lane is not weekly), {})
        icon_values = [short.get("remaining"), weekly.get("remaining")]
    images = {"icon": save(icon_png(icon_values[0], icon_values[1], palette, error=not result.get("ok"))),
              "icon_stale": save(icon_png(icon_values[0], icon_values[1], palette, stale=True))}
    for index, key in enumerate(("primary", "secondary")):
        value = values[index]
        images[key] = save(bar_png(value, palette))
        images[key + "_stale"] = save(bar_png(value, palette, stale=True))
    # Only pixels live on disk; bounded cache, no account or credential files.
    for old in sorted(directory.glob("*.png"), key=lambda path: path.stat().st_mtime, reverse=True)[96:]:
        if str(old) not in images.values():
            old.unlink(missing_ok=True)
    return images


def main():
    result: dict = {}
    try:
        result = collect()
    except Exception:
        # No traceback: even an unexpected exception must not disclose auth data.
        result = {"ok": False, "error": "internal_error"}
    try:
        supplied = object_or_empty(json.loads(sys.argv[1])) if len(sys.argv) > 1 else {}
        palette = {key: value if isinstance(value := supplied.get(key), int) and 0 <= value <= 0xffffffff else default
                   for key, default in DEFAULT_PALETTE.items()}
        result["images"] = render_assets(result, palette)
    except Exception:
        result["image_error"] = True  # Retain quota; disclose no exception details.
    print(json.dumps(result, ensure_ascii=False, allow_nan=False))


if __name__ == "__main__":
    main()
