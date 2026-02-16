-- Adapted from a combo of
-- https://lsp-zero.netlify.app/v3.x/blog/theprimeagens-config-from-2022.html
-- https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/lazy/lsp.lua
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
		"jay-babu/mason-nvim-dap.nvim",
	},
	config = function()
		local cmp_lsp = require("cmp_nvim_lsp")
		local lsp_zero = require("lsp-zero")

		lsp_zero.on_attach(function(client, bufnr)
			local opts = { buffer = bufnr, remap = false }
			lsp_zero.default_keymaps({ buffer = bufnr })

			-- Go to definition (both gd and <leader>gd)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })

			-- Go to references
			vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Go to references" })

			-- Hover
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

			-- Code actions
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })

			-- Rename
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })

			-- Diagnostics
			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { buffer = bufnr, desc = "Show diagnostic" })
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Previous diagnostic" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next diagnostic" })
		end)

		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		-- require("fidget").setup({})
		require("mason").setup({})
		require("mason-tool-installer").setup({
			ensure_installed = {
				-- Language Servers
				"lua-language-server",
				"typescript-language-server",
				"angular-language-server",
				"json-lsp",
				"yaml-language-server",
				"svelte-language-server",
				"gopls",

				-- Formatters
				"prettier",
				"stylua",
				"isort",
				"black",

				-- Linters
				"eslint_d",
				"pylint",
			},
		})
		require("mason-lspconfig").setup({
			ensure_installed = {
				"angularls",
				"ts_ls",
				"gopls",
				"jsonls",
				"svelte",
				"yamlls",
				"lua_ls",
			},
			handlers = {
				lsp_zero.default_setup,
				lua_ls = function()
					local lua_opts = lsp_zero.nvim_lua_ls()
					require("lspconfig").lua_ls.setup(lua_opts)
				end,
				ts_ls = function()
					local config_path = vim.fn.stdpath("config")
					require("lspconfig").ts_ls.setup({
						capabilities = capabilities,
						cmd = { config_path .. "/bin/typescript-language-server-quiet", "--stdio" },
						cmd_env = {
							NODE_NO_WARNINGS = "1",
						},
					})
				end,
				jsonls = function()
					local config_path = vim.fn.stdpath("config")
					require("lspconfig").jsonls.setup({
						capabilities = capabilities,
						cmd = { config_path .. "/bin/vscode-json-language-server-quiet", "--stdio" },
					})
				end,
				angularls = function()
					require("lspconfig").angularls.setup({
						capabilities = capabilities,
						filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
						-- Remove root_dir restriction to work in any directory with TS/HTML files
						root_dir = function(fname)
							local util = require("lspconfig.util")
							-- First try to find angular.json (proper Angular project)
							local angular_root = util.root_pattern("angular.json", "project.json")(fname)
							if angular_root then
								return angular_root
							end
							-- Fall back to any directory with package.json or git root
							return util.root_pattern("package.json", ".git")(fname) or vim.fn.getcwd()
						end,
					})
				end,
			},
			-- capabilities = capabilities
		})
		require("mason-nvim-dap").setup({
			ensure_installed = {
				"chrome",
			},
		})

		-- Setup nvim-cmp
		local cmp = require("cmp")
		cmp.setup({
			sources = {
				{ name = "copilot", group_index = 2 },
				{ name = "path" },
				{ name = "nvim_lsp" },
				{ name = "nvim_lua" },
				{ name = "luasnip" },
				{ name = "buffer" },
			},
			mapping = cmp.mapping.preset.insert({
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			}),
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
		})
	end,
}
