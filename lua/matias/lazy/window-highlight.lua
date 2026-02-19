return {
	"nvim-zh/colorful-winsep.nvim",
	config = function()
		require("colorful-winsep").setup({
			symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
			-- Rose-Pine style: soft pine/rose for active, muted for inactive
			coloring = {
				{ "#31748f", "Normal" },   -- pine (active)
				{ "#393552", "NormalNC" }, -- overlay (inactive)
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
