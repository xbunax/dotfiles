#!/bin/sh
set -eu

fail() {
    printf '%s\n' "$*" >&2
    exit 1
}

start_service=1
case ${1:-} in
    '') ;;
    --no-start) start_service=0; shift ;;
    -h|--help) printf 'Usage: sh install_sketchybar.sh [--no-start]\n'; exit 0 ;;
    *) fail 'Usage: sh install_sketchybar.sh [--no-start]' ;;
esac
[ "$#" -eq 0 ] || fail 'Usage: sh install_sketchybar.sh [--no-start]'
[ "$(uname -s)" = Darwin ] || fail 'SketchyBar requires macOS.'
[ "$(id -u)" -ne 0 ] || fail 'Run as your desktop user, not as root.'
if ! xcode-select -p >/dev/null 2>&1 || ! xcrun --find clang >/dev/null 2>&1; then
    fail 'Install Xcode Command Line Tools with xcode-select --install, then rerun.'
fi

if ! command -v brew >/dev/null 2>&1; then
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_bin" ]; then
            PATH="${brew_bin%/brew}:$PATH"
            break
        fi
    done
fi
command -v brew >/dev/null 2>&1 || fail 'Install Homebrew from https://brew.sh/ and rerun.'
brew_prefix=$(brew --prefix)
export PATH="$brew_prefix/bin:$brew_prefix/sbin:$PATH"

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
target="$config_home/sketchybar"
fonts="$HOME/Library/Fonts"
module_dir="$HOME/.local/share/sketchybar_lua"
if [ -e "$HOME/.sketchybarrc" ] || [ -L "$HOME/.sketchybarrc" ]; then
    printf 'Warning: %s may take precedence; move it aside if the new configuration does not load.\n' "$HOME/.sketchybarrc" >&2
fi
mkdir -p "$config_home"
stage=$(mktemp -d "$config_home/.sketchybar-install.XXXXXX")
trap 'rm -rf "$stage"' EXIT
trap 'exit 1' HUP INT TERM

printf 'Installing SketchyBar dependencies and fonts…\n'
brew install felixkratz/formulae/sketchybar lua jq python switchaudio-osx blueutil nowplaying-cli narugit/tap/smctemp acsandmann/tap/rift
brew install --cask sf-symbols font-sf-mono font-sf-pro

font_file=sketchybar-app-font.ttf
curl -fsSL --retry 3 \
    "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/$font_file" \
    -o "$stage/$font_file"
(cd "$stage" && printf '%s  %s\n' e49ee3281aca67634c2e7c0261d898226149664e9842b7fe61af8c4726d1f1de "$font_file" | shasum -a 256 -c -)

printf 'Downloading and building SketchyBar configuration…\n'
git clone --depth 1 --branch main https://github.com/xbunax/dotfiles.git "$stage/dotfiles"
config="$stage/dotfiles/sketchybar"
[ -x "$config/sketchybarrc" ] || fail 'The repository is missing an executable sketchybar/sketchybarrc.'
make -C "$config/helpers"

git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$stage/SbarLua"
make -C "$stage/SbarLua"
module="$stage/SbarLua/bin/sketchybar.so"
SBAR_MODULE="$module" lua -e 'assert(package.loadlib(os.getenv("SBAR_MODULE"), "luaopen_sketchybar"))'

mkdir -p "$fonts" "$module_dir" "$HOME/.config/wallpapers"
install -m 644 "$stage/$font_file" "$fonts/$font_file"
install -m 755 "$module" "$module_dir/sketchybar.so"

backup=''
if [ -e "$target" ] || [ -L "$target" ]; then
    backup=$(mktemp -d "$config_home/sketchybar-backup.XXXXXX")
    mv "$target" "$backup/sketchybar"
    printf 'Previous configuration saved to %s/sketchybar\n' "$backup"
fi
if ! mv "$config" "$target"; then
    if [ -n "$backup" ] && ! mv "$backup/sketchybar" "$target"; then
        fail "Could not restore the previous configuration; it is in $backup/sketchybar."
    fi
    fail 'Could not install the SketchyBar configuration.'
fi

if [ "$start_service" -eq 1 ]; then
    brew services restart sketchybar || fail "Configuration installed in $target, but SketchyBar did not start. Retry with: brew services restart sketchybar"
fi
printf 'SketchyBar configuration installed in %s\n' "$target"
printf 'To enable Rift workspaces, grant Rift Accessibility access and run: rift service install && rift service start\n'
