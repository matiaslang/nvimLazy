-- Optional: load with :colorscheme cyberdream or via Snacks picker <leader>uC
return {
	"scottmckendry/cyberdream.nvim",
	lazy = true,  -- not default; use Rose-Pine. Switch with <leader>uC or :colorscheme cyberdream
	config = function()
		local cyberdream = require("cyberdream")
		cyberdream.setup({
			italic_comments = true,
			hide_fillchars = true,
			borderless_pickers = true,
			terminal_colors = true,
		})
		-- vim.cmd.colorscheme("cyberdream")  -- uncomment to make this the default again

		-- -- Simple window highlighting
		-- vim.api.nvim_create_autocmd("WinEnter", {
		-- 	callback = function()
		-- 		vim.wo.winhl = "Normal:Normal"
		-- 	end,
		-- })
		-- vim.api.nvim_create_autocmd("WinLeave", {
		-- 	callback = function()
		-- 		vim.wo.winhl = "Normal:NormalNC"
		-- 	end,
		-- })
	end,
}
