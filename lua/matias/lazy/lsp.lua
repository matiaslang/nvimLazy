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
		"mfussenegger/nvim-dap",
		"jay-babu/mason-nvim-dap.nvim",
	},
	config = function()
		local cmp_lsp = require("cmp_nvim_lsp")
		local lsp_zero = require("lsp-zero")

		lsp_zero.on_attach(function(client, bufnr)
			local opts = { buffer = bufnr, remap = false }
			lsp_zero.default_keymaps({ buffer = bufnr })

			vim.keymap.set("n", "gd", function()
				vim.lsp.buf.definition()
			end, opts)
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover()
			end, opts)
			vim.keymap.set("n", "vca", function()
				vim.lsp.buf.code_action()
			end, opts)
			vim.keymap.set("n", "vrr", function()
				vim.lsp.buf.references()
			end, opts)
			vim.keymap.set("n", "vrn", function()
				vim.lsp.buf.rename()
			end, opts)
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
				"csharp-language-server",
				
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
				tsserver = function()
					local config_path = vim.fn.stdpath('config')
					require("lspconfig").tsserver.setup({
						capabilities = capabilities,
						cmd = { config_path .. "/bin/typescript-language-server-quiet", "--stdio" },
						cmd_env = {
							NODE_NO_WARNINGS = "1"
						}
					})
				end,
				jsonls = function()
					local config_path = vim.fn.stdpath('config')
					require("lspconfig").jsonls.setup({
						capabilities = capabilities,
						cmd = { config_path .. "/bin/vscode-json-language-server-quiet", "--stdio" }
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

		-- Manual C# LSP setup with wrapper
		local config_path = vim.fn.stdpath('config')
		require("lspconfig").csharp_ls.setup({
			capabilities = capabilities,
			cmd = { config_path .. "/bin/csharp-ls-wrapper" }
		})

		-- Angular LSP setup
		-- Note: This requires Node.js and TypeScript to be installed
		-- Update the paths below to match your Node.js installation
		local function setup_angular_lsp()
			-- Try to find Node.js installation dynamically
			local node_path = vim.fn.system("which node 2>/dev/null"):gsub("%s+", "")
			if node_path == "" then
				print("Warning: Node.js not found. Angular LSP may not work properly.")
				return
			end
			
			-- Derive lib path from node path
			local lib_path = node_path:gsub("/bin/node$", "/lib")
			local typescript_path = lib_path .. "/node_modules/typescript"
			
			-- Check if TypeScript is available globally
			local ts_check = vim.fn.system("test -d " .. typescript_path .. " && echo 'exists'")
			if ts_check:match("exists") == nil then
				print("Warning: Global TypeScript not found at " .. typescript_path .. ". Angular LSP may not work properly.")
			end
			
			require("lspconfig").angularls.setup({
				capabilities = capabilities,
				filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
				cmd = {
					config_path .. "/bin/ngserver",
					"--stdio",
					"--tsProbeLocations",
					typescript_path,
					"--ngProbeLocations",
					lib_path,
				},
				root_dir = require("lspconfig").util.root_pattern("angular.json", "project.json"),
				on_new_config = function(new_config, new_root_dir)
					new_config.cmd = {
						config_path .. "/bin/ngserver",
						"--stdio",
						"--tsProbeLocations",
						typescript_path,
						"--ngProbeLocations",
						new_root_dir,
					}
				end,
				settings = {
					["ng"] = {
						typescript = {
							tsdk = typescript_path .. "/lib",
						},
					},
				},
			})
		end
		
		setup_angular_lsp()

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
