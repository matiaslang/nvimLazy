return {
	"iabdelkareem/csharp.nvim",
	dependencies = {
		"williamboman/mason.nvim",
		"mfussenegger/nvim-dap",
		"Tastyep/structlog.nvim",
	},
	config = function()
		require("csharp").setup({
			lsp = {
				omnisharp = {
					enable = true,
					default_timeout = 1000,
					enable_editor_config_support = true,
					organize_imports = true,
					enable_analyzers_support = true,
					enable_import_completion = true,
					include_prerelease_sdks = true,
					enable_package_auto_restore = true,
				},
				roslyn = {
					enable = false,
				},
				on_attach = function(client, bufnr)
					-- Ensure EditorConfig support is enabled for formatting
					if client and not client.is_stopped() then
						local config = {
							settings = {
								omnisharp = {
									FormattingOptions = {
										EnableEditorConfigSupport = true,
									},
								},
							},
						}
						client.notify("workspace/didChangeConfiguration", config)
						vim.notify("OmniSharp EditorConfig support enabled", vim.log.levels.INFO)
					end
				end,
			},
			logging = {
				level = "TRACE",
			},
			dap = {
				adapter_name = nil,
			},
		})

		-- Apply fix for shell escaping issues with launch profiles
		require("matias.csharp-fix").setup()

		-- Debug helper: Check OmniSharp configuration
		local function check_omnisharp_config()
			local clients = vim.lsp.get_active_clients({ name = "omnisharp" })
			if #clients == 0 then
				vim.notify("OmniSharp is not running. Open a C# file first.", vim.log.levels.WARN)
				return
			end

			local client = clients[1]
			vim.notify("OmniSharp client found", vim.log.levels.INFO)
			vim.print("Client ID: " .. client.id)
			vim.print("Client name: " .. client.name)
			vim.print("Root directory: " .. (client.config.root_dir or "nil"))

			-- Request current configuration
			client.request("workspace/configuration", {
				items = { { section = "omnisharp" } },
			}, function(err, result)
				if err then
					vim.notify("Error getting config: " .. vim.inspect(err), vim.log.levels.ERROR)
					return
				end
				vim.print("Current OmniSharp config:")
				vim.print(vim.inspect(result))
			end)
		end

		-- Debug helper: Check if .editorconfig exists
		local function check_editorconfig()
			local buf = vim.api.nvim_get_current_buf()
			local file = vim.api.nvim_buf_get_name(buf)
			if file == "" then
				vim.notify("No file open", vim.log.levels.WARN)
				return
			end

			local dir = vim.fn.fnamemodify(file, ":h")
			local editorconfig_path = vim.fn.findfile(".editorconfig", dir .. ";")
			if editorconfig_path == "" then
				vim.notify("No .editorconfig found in project", vim.log.levels.WARN)
				vim.print("Searched from: " .. dir)
			else
				vim.notify("Found .editorconfig: " .. editorconfig_path, vim.log.levels.INFO)
				-- Read and display first few lines
				local lines = vim.fn.readfile(editorconfig_path)
				vim.print("\n.editorconfig contents (first 20 lines):")
				for i = 1, math.min(20, #lines) do
					vim.print(lines[i])
				end
			end
		end

		-- Debug helper: Manually trigger EditorConfig configuration
		local function trigger_editorconfig_config()
			local clients = vim.lsp.get_active_clients({ name = "omnisharp" })
			if #clients == 0 then
				vim.notify("OmniSharp is not running. Open a C# file first.", vim.log.levels.WARN)
				return
			end

			local client = clients[1]
			local config = {
				settings = {
					omnisharp = {
						FormattingOptions = {
							EnableEditorConfigSupport = true,
						},
					},
				},
			}
			client.notify("workspace/didChangeConfiguration", config)
			vim.notify("EditorConfig configuration sent to OmniSharp", vim.log.levels.INFO)
		end

		-- C# specific key mappings (using <leader>cs* to avoid conflicts)
		vim.keymap.set("n", "<leader>csr", function()
			require("csharp").run_project()
		end, { desc = "Run C# Project" })
		vim.keymap.set("n", "<leader>csd", function()
			print("Use DAP directly: <leader>Db for breakpoint, <leader>Dc to start debugging")
		end, { desc = "Use Direct DAP for C# Debug" })
		vim.keymap.set("n", "<leader>csu", "<cmd>CsharpFixUsings<cr>", { desc = "Fix C# Usings" })
		vim.keymap.set("n", "<leader>csf", "<cmd>CsharpFixAll<cr>", { desc = "Fix All C# Issues" })
		vim.keymap.set("n", "<leader>css", function()
			require("csharp").view_user_secrets()
		end, { desc = "View/Edit User Secrets" })
		vim.keymap.set("n", "<leader>csg", function()
			require("csharp").go_to_definition()
		end, { desc = "Go to Definition (with decompilation)" })

		-- Debug key mappings
		vim.keymap.set("n", "<leader>csDc", check_omnisharp_config, { desc = "Debug: Check OmniSharp Config" })
		vim.keymap.set("n", "<leader>csDe", check_editorconfig, { desc = "Debug: Check .editorconfig" })
		vim.keymap.set("n", "<leader>csDt", trigger_editorconfig_config, { desc = "Debug: Trigger EditorConfig Config" })
		vim.keymap.set("n", "<leader>csDl", function()
			vim.cmd("LspLog")
		end, { desc = "Debug: Open LSP Log" })
		vim.keymap.set("n", "<leader>csDi", function()
			vim.cmd("LspInfo")
		end, { desc = "Debug: Show LSP Info" })
	end,
}
