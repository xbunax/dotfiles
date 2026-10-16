-- Codex subscription quota, not local token/cost estimates.
local colors = require("colors")
local settings = require("settings")
local M = {}
local width = 250
local interval = 300
local config_dir = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")
local function quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

-- Credentials are read only inside Python, never passed in argv or through a shell.
-- Bound the entire subprocess as well as each HTTP operation.
local palette = string.format('{"white":%d,"grey":%d,"orange":%d,"red":%d,"blue":%d,"track":%d}',
	colors.white, colors.grey, colors.orange, colors.red, colors.blue, colors.bg2)
local command = "PYTHON=''; for p in /opt/homebrew/bin/python3 /usr/local/bin/python3 /usr/bin/python3; do "
	.. 'if [ -x "$p" ]; then PYTHON="$p"; break; fi; done; '
	.. 'if [ -n "$PYTHON" ]; then /usr/bin/perl -e '
	.. quote("alarm 20; exec @ARGV") .. ' "$PYTHON" ' .. quote(config_dir .. "/helpers/usage.py") .. " " .. quote(palette)
	.. [[ 2>/dev/null; else printf '%s\n' '{"ok":false,"error":"python_missing"}'; fi]]

local state = { busy = false, failures = 0, next_attempt = 0, last_attempt = 0, cooldown = 0 }
local messages = {
	auth_missing = "未找到 Codex 登录，请运行 codex login",
	auth_invalid = "登录信息异常，请重新运行 codex login",
	auth_expired = "登录已过期，请通过 Codex 重新认证",
	auth_changed = "登录已变更，等待重新读取",
	network_error = "网络不可用，稍后自动重试",
	server_error = "服务暂不可用，稍后自动重试",
	rate_limited = "请求受限，等待冷却后重试",
	invalid_response = "用量响应异常，稍后重试",
	no_windows = "当前账号暂无可用额度窗口",
	python_missing = "缺少 Python 3，无法读取用量",
	internal_error = "读取失败，请检查 Python 与辅助脚本",
}
local transient = { network_error = true, server_error = true, rate_limited = true, invalid_response = true }

M.usage = sbar.add("item", "widgets.usage", {
	position = "right",
	updates = "on",
	update_freq = 30,
	icon = { string = "◫", width = 22, color = colors.grey },
	label = { string = "", drawing = false, width = 0, padding_left = 0, padding_right = 0 },
	background = { color = colors.transparent, border_width = 0 },
	padding_left = 5,
	padding_right = 0,
	popup = { align = "center", drawing = false, height = 28 },
})

local function row(name, left, right)
	return sbar.add("item", "widgets.usage." .. name, {
		position = "popup." .. M.usage.name,
		width = width,
		padding_left = 12,
		padding_right = 12,
		icon = { string = left or "", width = 125, align = "left", padding_left = 0, padding_right = 0 },
		label = { string = right or "", width = 131, align = "right", padding_left = 0, padding_right = 0,
			font = { family = settings.font.numbers, size = 12 } },
		background = { color = colors.transparent, border_width = 0 },
	})
end

local header = row("header", "", "Codex")
header:set({ icon = { drawing = false, width = 0 },
	label = { width = 256, align = "center", color = colors.white,
		font = { family = settings.font.text, style = settings.font.style_map["Bold"], size = 14 } },
	background = { color = colors.popup.border, height = 1, y_offset = -14, corner_radius = 0 } })
local plan_row = row("plan", "订阅套餐", "读取中…")

local lanes = {}
for _, key in ipairs({ "primary", "secondary" }) do
	local title = row(key .. ".title", "额度窗口", "暂无数据")
	local bar = row(key .. ".bar", "", "")
	bar:set({ icon = { width = 0, drawing = false }, label = { width = 256, align = "center", color = colors.grey, font = { size = 10 } } })
	local reset = row(key .. ".reset", "额度重置", "时间未知")
	reset:set({ icon = { width = 90, color = colors.grey, font = { size = 12 } },
		label = { width = 166, color = colors.grey, font = { size = 11 } } })
	lanes[key] = { title = title, bar = bar, reset = reset }
end

local status = row("status", "", "首次读取中…")
status:set({ drawing = false, icon = { drawing = false, width = 0 }, label = { width = 256, align = "left", color = colors.grey, font = { family = settings.font.text, size = 10 } } })
local detail = row("detail", "", "")
detail:set({ drawing = false, icon = { drawing = false, width = 0 },
	label = { width = 256, align = "left", color = colors.orange, font = { family = settings.font.text, size = 10 } } })
local refresh_item = row("refresh", "首次读取中…", "↻ 刷新")
refresh_item:set({ icon = { width = 190, color = colors.grey, font = { size = 10 } },
	label = { width = 66, color = colors.blue, font = { family = settings.font.text, size = 11 } } })

local function remaining_color(value)
	if value <= 10 then return colors.red end
	if value <= 20 then return colors.orange end
	return colors.blue
end

local function percent(value)
	-- Flooring avoids advertising 100% when some quota has already been used.
	if value > 0 and value < 1 then return "<1%" end
	return math.floor(value) .. "%"
end

local function duration(seconds)
	local minutes = math.max(1, math.ceil(seconds / 60))
	if minutes >= 1440 then return math.floor(minutes / 1440) .. "d " .. math.floor(minutes % 1440 / 60) .. "h" end
	if minutes >= 60 then return math.floor(minutes / 60) .. "h " .. minutes % 60 .. "m" end
	return minutes .. "m"
end

local function window_name(lane, key)
	if not lane then return key == "primary" and "当前窗口" or "长期额度" end
	if lane.seconds == 604800 then return "每周额度" end
	if lane.seconds % 86400 == 0 then return math.floor(lane.seconds / 86400) .. " 天额度" end
	if lane.seconds % 3600 == 0 then return math.floor(lane.seconds / 3600) .. " 小时窗口" end
	return math.floor(lane.seconds / 60) .. " 分钟窗口"
end

local function render()
	local now, data = os.time(), state.data
	local stale = data and (state.error ~= nil or now - data.updated_at >= interval * 2)
	if data then
		for _, key in ipairs({ "primary", "secondary" }) do
			local lane = data[key]
			if lane and lane.reset_at and lane.reset_at <= now then stale = true end
		end
	end
	local images = data and data.images or state.images
	local icon_path = type(images) == "table" and images[stale and "icon_stale" or "icon"] or nil
	M.usage:set({
		icon = { string = icon_path and "" or "◫", background = {
			drawing = icon_path ~= nil, height = 18, color = colors.transparent,
			image = { string = icon_path or "", drawing = icon_path ~= nil, scale = 0.5, corner_radius = 0 },
		} },
		label = { string = "", drawing = false, width = 0, padding_left = 0, padding_right = 0 },
	})
	local plans = { prolite = "Pro Lite", pro = "Pro", plus = "Plus", team = "Team", business = "Business", enterprise = "Enterprise", free = "Free" }
	plan_row:set({ label = { string = data and (plans[data.plan] or data.plan:gsub("_", " ")) or "未连接" } })
	for _, key in ipairs({ "primary", "secondary" }) do
		local lane, ui = data and data[key], lanes[key]
		-- Some plans expose only one real window. Do not add empty quota lanes.
		ui.title:set({ drawing = lane ~= nil or (not data and key == "primary") })
		ui.bar:set({ drawing = lane ~= nil })
		ui.reset:set({ drawing = lane ~= nil })
		local color = stale and colors.grey or (lane and remaining_color(lane.remaining) or colors.grey)
		ui.title:set({ icon = { string = window_name(lane, key) },
			label = { string = lane and ("剩余 " .. percent(lane.remaining)) or "暂无数据", color = color } })
		if lane then
			local filled = math.floor(lane.remaining / 5)
			ui.bar:set({ label = { string = string.rep("━", filled) .. string.rep("╌", 20 - filled), color = color } })
		else
			ui.bar:set({ label = { string = "—", color = colors.grey } })
		end
		local bar_path = type(images) == "table" and images[key .. (stale and "_stale" or "")] or nil
		ui.bar:set({
			icon = { string = "", drawing = bar_path ~= nil, width = bar_path and 256 or 0,
				align = "center", background = { drawing = bar_path ~= nil, height = 6, color = colors.transparent,
					image = { string = bar_path or "", drawing = bar_path ~= nil, scale = 0.5, corner_radius = 0 } } },
			label = { drawing = bar_path == nil },
		})
		local reset_text = "重置时间未知"
		if lane and lane.reset_at then
			reset_text = lane.reset_at > now and (duration(lane.reset_at - now) .. " 后重置") or "窗口已到期，等待刷新"
		end
		ui.reset:set({ label = { string = reset_text } })
	end
	local status_text = data and ("更新于 " .. duration(now - data.updated_at) .. "前") or "尚无订阅用量数据"
	if data and now - data.updated_at < 60 then status_text = "刚刚更新" end
	if stale then status_text = status_text .. " · 数据已过期" end
	if state.busy then status_text = "正在读取用量…" end
	status:set({ label = { string = status_text } })
	detail:set({ drawing = state.error ~= nil, label = { string = messages[state.error] or "" } })
	refresh_item:set({ icon = { string = status_text }, label = { string = state.busy and "读取中" or "↻ 刷新" } })
end

local function valid_data(result)
	if type(result.identity) ~= "string" or type(result.updated_at) ~= "number" or type(result.plan) ~= "string" then return false end
	local found = false
	for _, key in ipairs({ "primary", "secondary" }) do
		local lane = result[key]
		if type(lane) == "table" then
			if type(lane.remaining) ~= "number" or lane.remaining < 0 or lane.remaining > 100
				or type(lane.seconds) ~= "number" or lane.seconds <= 0 then return false end
			if type(lane.reset_at) ~= "number" then lane.reset_at = nil end
			found = true
		else
			result[key] = nil -- sbar JSON null is not necessarily Lua nil.
		end
	end
	return found
end

local function refresh(force)
	local now = os.time()
	if state.busy or now < state.cooldown or now - state.last_attempt < 15 then return end
	if not force and now < state.next_attempt then return end
	state.busy, state.last_attempt = true, now
	render()
	sbar.exec(command, function(result)
		state.busy = false
		if type(result) ~= "table" then result = { ok = false, error = "internal_error" } end
		state.images = type(result.images) == "table" and result.images or nil
		if result.ok == true and valid_data(result) then
			state.data, state.error, state.failures = result, nil, 0
			state.next_attempt, state.cooldown = os.time() + interval, 0
		else
			local code = type(result.error) == "string" and result.error or "internal_error"
			state.error = messages[code] and code or "internal_error"
			if not (transient[code] and state.data and state.data.identity == result.identity) then state.data = nil end
			state.failures = math.min(state.failures + 1, 6)
			local delay = math.min(60 * 2 ^ (state.failures - 1), 1800)
			if code == "rate_limited" then
				delay = math.max(delay, math.min(3600, tonumber(result.retry_after) or 300))
				state.cooldown = os.time() + delay
			end
			state.next_attempt = os.time() + delay
		end
		render()
	end)
end

M.usage:subscribe("routine", function() render(); refresh(false) end)
M.usage:subscribe("system_woke", function() refresh(true) end)
M.usage:subscribe("mouse.clicked", function(env)
	if env.BUTTON == "right" then refresh(true); return end
	M.usage:set({ popup = { drawing = "toggle" } })
	render()
	refresh(false)
end)
M.usage:subscribe("mouse.exited.global", function() M.usage:set({ popup = { drawing = false } }) end)
refresh_item:subscribe("mouse.clicked", function() refresh(true) end)
refresh_item:subscribe("mouse.entered", function() refresh_item:set({ background = { color = colors.bg1 } }) end)
refresh_item:subscribe("mouse.exited", function() refresh_item:set({ background = { color = colors.transparent } }) end)
refresh(false)
return M
