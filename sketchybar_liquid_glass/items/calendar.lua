local settings = require("settings")
local colors = require("colors")

local M = {}

M.cal = sbar.add("item", "cal", {
	icon = {
		color = colors.white,
		padding_left = 6,
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
	},
	label = {
		color = colors.white,
		padding_right = 10,
		width = 80,
		align = "right",
		font = { family = settings.font.numbers },
	},
	position = "right",
	update_freq = 1,
	padding_left = 1,
	padding_right = 1,
	background = {
		color = colors.transparent,
		border_color = colors.black,
		border_width = 0,
	},
	popup = { align = "right" },
})

local days_per_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

local function get_days_in_month(y, m)
	if m == 2 and ((y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0) then
		return 29
	end
	return days_per_month[m]
end

local function build_calendar()
	sbar.remove("/cal\\.popup\\..*/")

	local now = os.time()
	local year = tonumber(os.date("%Y", now))
	local month = tonumber(os.date("%m", now))
	local today = tonumber(os.date("%d", now))

	local month_names = {
		"January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December",
	}

	local wday = tonumber(os.date("%w", os.time({ year = year, month = month, day = 1 })))
	local first_wday = wday == 0 and 7 or wday -- 1=Mon .. 7=Sun

	local num_days = get_days_in_month(year, month)

	local mono = {
		family = settings.font.numbers,
		style = settings.font.style_map["Regular"],
		size = 12.0,
	}
	local CHAR_W = 7.2

	sbar.add("item", "cal.popup.header", {
		position = "popup." .. M.cal.name,
		width = 220,
		icon = {
			width = 200,
			string = month_names[month] .. " " .. year,
			font = {
				family = settings.font.text,
				style = settings.font.style_map["Bold"],
				size = 14.0,
			},
			color = colors.white,
			align = "center",
		},
		label = { drawing = false },
	    align = "center",
	})

	sbar.add("item", "cal.popup.wdays", {
		position = "popup." .. M.cal.name,
		icon = {
			string = " Mo  Tu  We  Th  Fr  Sa  Su ",
			font = {
				family = settings.font.numbers,
				style = settings.font.style_map["Bold"],
				size = 12.0,
			},
			color = colors.grey,
			padding_left = 10,
			padding_right = 10,
		},
		label = { drawing = false },
	})

	local day = 1
	local week = 0
	while day <= num_days do
		week = week + 1
		local row = ""
		local leading_empty = 0

		for col = 1, 7 do
			if day == 1 and col < first_wday then
				leading_empty = leading_empty + 1
			elseif day > num_days then
				row = row .. "    "
			else
				if day == today then
					row = row .. string.format("[%2d]", day)
				else
					row = row .. string.format(" %2d ", day)
				end
				day = day + 1
			end
		end

		sbar.add("item", "cal.popup.week" .. week, {
			position = "popup." .. M.cal.name,
			icon = {
				string = row,
				font = mono,
				color = colors.white,
				padding_right = 10,
				padding_left = 10 + math.floor(leading_empty * 4 * CHAR_W),
			},
		})
	end
end

M.cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
	M.cal:set({ icon = os.date("%a. %d %b "), label = os.date("%H:%M:%S") })
end)

M.cal:subscribe("mouse.clicked", function(env)
	local query = M.cal:query()
	local drawing = query and query.popup and query.popup.drawing
	if drawing ~= "on" then
		build_calendar()
	end
	M.cal:set({ popup = { drawing = "toggle" } })
end)

-- M.cal:subscribe("mouse.exited.global", function(env)
-- 	M.cal:set({ popup = { drawing = false } })
-- end)

return M
