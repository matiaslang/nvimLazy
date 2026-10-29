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

		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		vim.lsp.config("*", { capabilities = capabilities })

		-- vtsls and angularls both attach to .ts files and return identical results;
		-- deduplicate by location before showing any list.
		local function dedup(items)
			local seen, result = {}, {}
			for _, item in ipairs(items) do
				local key = (item.filename or "") .. (item.lnum or 0) .. (item.col or 0)
				if not seen[key] then seen[key] = true; result[#result + 1] = item end
			end
			return result
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local bufnr = args.buf
				local opts = { buffer = bufnr }

				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
				vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
				vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
				vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)

				vim.keymap.set("n", "gr", function()
					vim.lsp.buf.references(nil, { on_list = function(o)
						local items = dedup(o.items)
						vim.fn.setqflist({}, " ", { title = o.title, items = items })
						vim.cmd("botright copen")
					end })
				end, opts)

				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition({ on_list = function(options)
						local items = dedup(options.items)
						if #items == 1 then
							vim.cmd("normal! m'")
							vim.cmd("edit +" .. items[1].lnum .. " " .. vim.fn.fnameescape(items[1].filename))
							vim.api.nvim_win_set_cursor(0, { items[1].lnum, items[1].col - 1 })
						elseif #items > 1 then
							vim.fn.setqflist({}, " ", { title = options.title, items = items })
							vim.cmd("botright copen")
						end
					end })
				end, opts)
			end,
		})

		-- angularls: the default cmd uses getcwd() for probe locations, which in a
		-- monorepo is the repo root rather than the Angular project root. That points
		-- --ngProbeLocations at the wrong node_modules and angularls either exits or
		-- can't find @angular/language-server. Fix: resolve root from the current
		-- buffer, probe project node_modules first so the project-local language-
		-- service is found before Mason's.
		vim.lsp.config("angularls", {
			cmd = function(dispatchers)
				local fs, fn, uv = vim.fs, vim.fn, vim.uv
				local root = vim.fs.root(0, { "angular.json", "nx.json" }) or fn.getcwd()

				local node_paths = {}
				local project_nm = fs.joinpath(root, "node_modules")
				if uv.fs_stat(project_nm) then
					table.insert(node_paths, project_nm)
				end
				local ngserver_exe = fn.exepath("ngserver")
				if ngserver_exe and #ngserver_exe > 0 then
					local realpath = uv.fs_realpath(ngserver_exe) or ngserver_exe
					local mason_nm = fs.normalize(fs.joinpath(fs.dirname(realpath), "../../.."))
					if uv.fs_stat(mason_nm) then
						table.insert(node_paths, mason_nm)
					end
				end
				local probe = table.concat(node_paths, ",")

				local project_ngserver = fs.joinpath(root, "node_modules", ".bin", "ngserver")
				local ngserver_bin = uv.fs_stat(project_ngserver) and project_ngserver or "ngserver"

				return vim.lsp.rpc.start({
					ngserver_bin,
					"--stdio",
					"--tsProbeLocations", probe,
					"--ngProbeLocations", probe,
				}, dispatchers)
			end,
		})

		-- vtsls instead of ts_ls: scans all tsconfig*.json files in the workspace,
		-- picking up tsconfig.sonar.json / tsconfig.nvim.json which have
		-- include:["src/**/*.ts"] and inherit baseUrl:"./" from tsconfig.json.
		-- autoUseWorkspaceTsdk: use the project's own TypeScript, same version
		-- Angular CLI uses, so types and module resolution match exactly.
		vim.lsp.config("vtsls", {
			settings = {
				vtsls = { autoUseWorkspaceTsdk = true },
			},
		})

		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			settings = {
				Lua = { diagnostics = { globals = { "vim" } } },
			},
		})

		require("mason").setup({})
		require("mason-tool-installer").setup({
			ensure_installed = {
				"lua-language-server",
				"vtsls",
				"angular-language-server",
				"json-lsp",
				"yaml-language-server",
				"svelte-language-server",
				"gopls",
				"prettier",
				"stylua",
				"isort",
				"black",
				"pylint",
				"sonarlint-language-server",
			},
		})
		require("mason-lspconfig").setup({
			ensure_installed = {
				"angularls",
				"vtsls",
				"gopls",
				"jsonls",
				"svelte",
				"yamlls",
				"lua_ls",
			},
			-- ts_ls is excluded: vtsls replaces it. Without this, mason-lspconfig's
			-- automatic_enable starts ts_ls for every installed typescript-language-server.
			automatic_enable = {
				exclude = { "ts_ls" },
			},
		})
		require("mason-nvim-dap").setup({
			ensure_installed = {
				"chrome",
			},
		})

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
