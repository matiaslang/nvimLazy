return {
	"nvim-zh/colorful-winsep.nvim",
	config = function()
		require("colorful-winsep").setup({
			-- No symbols, just colors
			symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
			-- Bright colors for active window
			coloring = {
				{ "#42f7ff", "Normal" },
				{ "#606b81", "NormalNC" },
			},
			-- Make the separator more prominent
			create_event = function()
				vim.api.nvim_create_autocmd({ "WinEnter", "VimEnter" }, {
					callback = function()
						-- Force highlight inactive windows
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							if win ~= vim.api.nvim_get_current_win() then
								vim.api.nvim_win_set_option(win, "winhighlight", "Normal:NormalNC")
							end
						end
					end,
				})
			end,
		})
	end,
}
