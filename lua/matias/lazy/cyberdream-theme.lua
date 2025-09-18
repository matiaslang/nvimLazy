return {
	"scottmckendry/cyberdream.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local cyberdream = require("cyberdream")

		cyberdream.setup({
			-- transparent = true,
			-- variant = "light",
			italic_comments = true,
		})
		vim.cmd.colorscheme("cyberdream")
		
		-- Simple window highlighting
		vim.api.nvim_create_autocmd("WinEnter", {
			callback = function()
				vim.wo.winhl = "Normal:Normal"
			end,
		})
		vim.api.nvim_create_autocmd("WinLeave", {
			callback = function()
				vim.wo.winhl = "Normal:NormalNC"
			end,
		})
	end,
}
