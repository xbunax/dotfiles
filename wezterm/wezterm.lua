local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
-- local workspace_saver = require("wezterm_workspace_saver")

-- wezterm.on("save_state", function(window) workspace_saver.save_state(window) end)
-- wezterm.on("load_state", function() workspace_saver.load_state() end)
-- wezterm.on("restore_state", function(window) workspace_saver.restore_state(window) end)

wezterm.on("toggle-opacity", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 0.30
	else
		overrides.window_background_opacity = nil
	end
	window:set_config_overrides(overrides)
end)

wezterm.on("center-window", function(window, pane)
	window:set_position(570, 240)
	window:set_inner_size(812, 511)
end)

wezterm.on("gui-startup", function(cmd) -- set startup Window position
	local screens = wezterm.gui.screens()

	if screens.virtual_width > 1920 then
		local tab, pane, window = mux.spawn_window({ position = { x = 2480, y = 240 } })
	else
		local tab, pane, window = mux.spawn_window({ position = { x = 560, y = 240 } })
	end
end)

local process_icons = {
	["docker"] = wezterm.nerdfonts.linux_docker,
	["docker-compose"] = wezterm.nerdfonts.linux_docker,
	["psql"] = wezterm.nerdfonts.dev_postgresql,
	["kuberlr"] = wezterm.nerdfonts.linux_docker,
	["kubectl"] = wezterm.nerdfonts.linux_docker,
	["stern"] = wezterm.nerdfonts.linux_docker,
	["nvim"] = wezterm.nerdfonts.custom_vim,
	["make"] = wezterm.nerdfonts.seti_makefile,
	["vim"] = wezterm.nerdfonts.dev_vim,
	["go"] = wezterm.nerdfonts.seti_go,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
	["bash"] = wezterm.nerdfonts.cod_terminal_bash,
	["btm"] = wezterm.nerdfonts.mdi_chart_donut_variant,
	["htop"] = wezterm.nerdfonts.mdi_chart_donut_variant,
	["cargo"] = wezterm.nerdfonts.dev_rust,
	["sudo"] = wezterm.nerdfonts.fa_hashtag,
	["lazydocker"] = wezterm.nerdfonts.linux_docker,
	["git"] = wezterm.nerdfonts.dev_git,
	["lua"] = wezterm.nerdfonts.seti_lua,
	["wget"] = wezterm.nerdfonts.mdi_arrow_down_box,
	["curl"] = wezterm.nerdfonts.mdi_flattr,
	["gh"] = wezterm.nerdfonts.dev_github_badge,
	["ruby"] = wezterm.nerdfonts.cod_ruby,
	["pwsh"] = wezterm.nerdfonts.seti_powershell,
	["node"] = wezterm.nerdfonts.dev_nodejs_small,
	["dotnet"] = wezterm.nerdfonts.md_language_csharp,
}
--
-- Functions
local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return basename(tab_info.active_pane.title)
end

-- This table will hold the configuration.
local config = {}

config.initial_rows = 24
config.initial_cols = 80

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Shell
config.default_prog = {
	"powershell.exe",
	"-NoLogo",
}

-- Colorscheme
config.color_scheme = "Gruvbox dark, medium (base16)"
local catppuccin_colors = {
	"#f5c2e7", -- pink
	"#cba6f7", -- mauve
	"#f38ba8", -- red
	"#fab387", -- peach
	"#f9e2af", -- yellow
	"#a6e3a1", -- green
	"#94e2d5", -- teal
	"#89b4fa", -- blue
}

-- Window Frame
config.window_frame = {
	border_left_width = "1px",
	border_right_width = "1px",
	border_bottom_height = "1px",
	border_top_height = "1px",
	-- border_left_color = catppuccin_colors[2],
	-- border_right_color = catppuccin_colors[2],
	-- border_bottom_color = catppuccin_colors[2],
	-- border_top_color = catppuccin_colors[2],
}

-- Background
config.window_background_opacity = 0.30
config.max_fps = 165
config.win32_system_backdrop = "Acrylic"

-- Font
config.font = wezterm.font_with_fallback({ "JetBrainsMono Nerd Font" })
config.font_size = 12.0

-- Window
config.window_decorations = "RESIZE" -- removes close, minimize and so on
config.window_close_confirmation = "AlwaysPrompt"
config.window_padding = {
	top = 5,
	right = 5,
	bottom = 0,
	left = 5,
}

-- General
config.scrollback_lines = 3000

-- Tab/Status Bar
-- disables the 'modern' look of the tab bar
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.status_update_interval = 1000
config.tab_max_width = 60
config.tab_bar_at_bottom = false

local tab_bar_bg = "#181825"
config.colors = {
	tab_bar = {
		background = tab_bar_bg,
	},
}

local tab_min_width = 11
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle
-- local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local color = catppuccin_colors[tab.tab_index % #catppuccin_colors + 1]

	local title = tab_title(tab)
	local title_len = string.len(title)
	-- local pane = tab.active_pane
	-- local title = basename(pane.foreground_process_name)
	local bg = color
	local fg = "#1E1E2E"
	local right_arrow_bg = tab_bar_bg
	local right_arrow_fg = color
	local left_arrow_bg = tab_bar_bg
	local left_arrow_fg = color
	if not tab.is_active then
		bg = "#1E1E2E"
		fg = "#CDD6F4"
		right_arrow_fg = "#1E1E2E"
		left_arrow_fg = "#1E1E2E"

		if title_len > 10 then
			title = string.sub(title, 1, tab_min_width - 3) .. "..."
		end
	end

	if title_len < tab_min_width then
		title = title .. string.rep(" ", tab_min_width - title_len)
	end

	local next_tab = tabs[tab.tab_index + 2]
	-- if next_tab ~= nil and next_tab.is_active then
	-- right_arrow_bg = color
	-- end

	if next_tab == nil then
		right_arrow_bg = tab_bar_bg
	end

	local prev_tab = tabs[tab.tab_index]
	if prev_tab == nil then
		left_arrow_bg = "#1E1E2E"
		if tab.is_active then
			left_arrow_bg = color
		end
	end

	return {
		{ Background = { Color = left_arrow_bg } },
		{ Foreground = { Color = left_arrow_fg } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = " [" .. tab.tab_index + 1 .. "] " .. title .. " " },
		{ Background = { Color = right_arrow_bg } },
		{ Foreground = { Color = right_arrow_fg } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
	local zoomed = ""
	if tab.active_pane.is_zoomed then
		zoomed = "[Z] "
	end

	local index = ""
	if #tabs > 1 then
		index = string.format("[ %d / %d ] ", tab.tab_index + 1, #tabs)
	end

	return zoomed .. index
end)

-- Panes
config.inactive_pane_hsb = {
	-- saturation = 0.4,
	brightness = 0.7,
}

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "ALT" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if pane:is_alt_screen_active() then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "ALT" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 1 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
			-- if is_vim(pane) then
			--   -- pass the keys through to vim/nvim
			--   win:perform_action({
			--     SendKey = { key = key, mods = resize_or_move == 'resize' and 'ALT' or 'CTRL' },
			--   }, pane)
			-- else
			--   if resize_or_move == 'resize' then
			--     win:perform_action({ AdjustPaneSize = { direction_keys[key], 1 } }, pane)
			--   else
			--     win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
			--   end
			-- end
		end),
	}
end

local function scroll(direction, key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if pane:is_alt_screen_active() then
				-- pass the keys to running screen
				win:perform_action({
					SendKey = { key = key, mods = "CTRL" },
				}, pane)
			else
				win:perform_action({ ScrollByPage = direction }, pane)
			end

			-- if is_vim(pane) then
			--   -- pass the keys through to vim/nvim
			--   win:perform_action({
			--     SendKey = { key = key, mods = 'CTRL' },
			--   }, pane)
			-- elseif pane:is_alt_screen_active() then
			--   -- pass the keys to running screen
			--   win:perform_action({
			--     SendKey = { key = key, mods = 'CTRL' },
			--   }, pane)
			-- else
			--   win:perform_action({ ScrollByPage = direction }, pane)
			-- end
		end),
	}
end

-- Keys
config.leader = {
	key = "Space",
	mods = "CTRL",
	timeout_milliseconds = 3000,
}

config.keys = { -- This will create a new split and run the `top` program inside it
	{
		key = "]",
		mods = "LEADER",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "[",
		mods = "LEADER",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "v",
		mods = "LEADER",
		action = act.SplitPane({
			direction = "Right",
			-- command = { args = { "top" } },
			size = {
				Percent = 50,
			},
		}),
	},
	{
		key = "s",
		mods = "LEADER",
		action = act.SplitPane({
			direction = "Down",
			-- command = { args = { "top" } },
			size = {
				Percent = 50,
			},
		}),
	},
	{
		key = "}",
		mods = "LEADER|SHIFT",
		action = act.MoveTabRelative(1),
	},
	{
		key = "{",
		mods = "LEADER|SHIFT",
		action = act.MoveTabRelative(-1),
	},
	{
		key = "0",
		mods = "LEADER",
		action = act.PaneSelect({
			mode = "SwapWithActiveKeepFocus",
			alphabet = "1234567890",
		}),
	},
	-- move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
	{
		key = "x",
		mods = "LEADER",
		action = act.CloseCurrentPane({
			confirm = true,
		}),
	},
	scroll(-0.5, "u"),
	scroll(0.5, "d"),
	scroll(-1, "b"),
	scroll(1, "f"),
	{
		key = "n",
		mods = "CTRL|SHIFT",
		action = act.EmitEvent("gui-startup"),
	},
	{
		key = "n",
		mods = "LEADER",
		action = act.SpawnTab("DefaultDomain"),
	},
	{
		key = "B",
		mods = "CTRL|SHIFT",
		action = act.EmitEvent("toggle-opacity"),
	},
	{
		key = "o",
		mods = "CTRL|SHIFT",
		action = act.EmitEvent("center-window"),
	},
	{
		key = "0",
		mods = "CTRL",
		action = act.PaneSelect({
			mode = "SwapWithActiveKeepFocus",
			alphabet = "1234567890",
		}),
	},
}

config.key_tables = {
	search_mode = {
		{
			key = "Enter",
			mods = "NONE",
			action = act.CopyMode("PriorMatch"),
		},
		{
			key = "Escape",
			mods = "NONE",
			action = act.CopyMode("Close"),
		},
		{
			key = "n",
			mods = "CTRL",
			action = act.CopyMode("NextMatch"),
		},
		{
			key = "n",
			mods = "CTRL|SHIFT",
			action = act.CopyMode("PriorMatch"),
		},
	},
}

return config
