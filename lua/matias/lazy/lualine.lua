return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
	priority = 50, -- load early so statusline is styled from the start
	config = function()
		-- Sleek 1-letter mode for statusline
		local function mode_short()
			local m = vim.fn.mode()
			local map = { n = "N", i = "I", v = "V", V = "V", ["\22"] = "V", c = "C", R = "R", s = "S", t = "T" }
			return map[m] or m:sub(1, 1)
		end

		-- Follow the active colorscheme (Rose-Pine, Cyberdream, etc.)
		require("lualine").setup({
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
				disabled_filetypes = { statusline = { "alpha", "dashboard" } },
				ignore_focus = {},
			},
			sections = {
				lualine_a = {
					{ mode_short, padding = { left = 1, right = 1 } },
				},
				lualine_b = {
					{ "branch", icon = "", padding = { left = 0, right = 1 } },
				},
				lualine_c = {
					{
						"filename",
						path = 1,
						symbols = { modified = " ●", readonly = " ", unnamed = "" },
						padding = { left = 0, right = 1 },
					},
				},
				lualine_x = {
					{ "diagnostics", symbols = { error = "E", warn = "W", info = "I", hint = "H" }, padding = { left = 0, right = 1 } },
					{ "filetype", padding = { left = 0, right = 1 } },
					{ "progress", padding = { left = 0, right = 0 } },
					{ "location", padding = { left = 1, right = 1 } },
				},
				lualine_y = {},
				lualine_z = {},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{ "filename", path = 1, padding = { left = 1, right = 1 } },
				},
				lualine_x = { { "location", padding = { left = 1, right = 1 } } },
				lualine_y = {},
				lualine_z = {},
			},
		})

		-- Distinct statusline bar background (slightly elevated so it’s visible)
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				-- Rose-Pine base; statusline bar stays distinct
				local sl_bg = "#191724"
				vim.api.nvim_set_hl(0, "StatusLine",   { bg = sl_bg })
				vim.api.nvim_set_hl(0, "StatusLineNC", { bg = sl_bg })
			end,
		})
		vim.schedule(function() vim.api.nvim_exec_autocmds("ColorScheme", {}) end)
	end,
}
