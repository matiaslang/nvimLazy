return {
	"zbirenbaum/copilot.lua",
	config = function()
		require("copilot").setup({
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = "<C-y>",
					accept_word = "<C-Right>",
					accept_line = "<C-Down>",
					next = "<C-n>",
					prev = "<C-p>",
					dismiss = "<C-e>",
				},
			},
		})
	end,
}
