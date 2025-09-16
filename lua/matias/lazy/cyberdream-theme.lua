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
	end,
}
