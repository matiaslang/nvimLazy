return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local ok_dap, dap = pcall(require, "dap")
		if not ok_dap then
			vim.notify("Failed to load nvim-dap: " .. tostring(dap), vim.log.levels.ERROR)
			return
		end

		local ok_ui, dapui = pcall(require, "dapui")
		if not ok_ui then
			vim.notify("Failed to load nvim-dap-ui: " .. tostring(dapui), vim.log.levels.ERROR)
			return
		end

		-- Setup DAP UI
		dapui.setup()

		-- Auto open/close DAP UI
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- C# DAP Configuration
		local netcoredbg_path = vim.fn.expand("~/.local/share/nvim/mason/bin/netcoredbg")

		dap.adapters.coreclr = {
			type = "executable",
			command = netcoredbg_path,
			args = { "--interpreter=vscode" },
		}

		-- Helper function to find and build project, then return DLL path
		local function find_dll()
			local cwd = vim.fn.getcwd()
			
			-- Find .csproj file
			local csproj_files = vim.fn.globpath(cwd, "*.csproj", 0, 1)
			if not csproj_files or #csproj_files == 0 then
				csproj_files = vim.fn.globpath(cwd, "**/*.csproj", 0, 1)
			end
			
			if not csproj_files or #csproj_files == 0 then
				vim.notify("No .csproj file found", vim.log.levels.ERROR)
				error("No .csproj file found")
			end
			
			-- Filter out test projects
			local main_projects = {}
			for _, proj in ipairs(csproj_files) do
				if not string.match(proj:lower(), "test") then
					table.insert(main_projects, proj)
				end
			end
			
			local project_file = (#main_projects > 0 and main_projects[1]) or csproj_files[1]
			local project_name = vim.fn.fnamemodify(project_file, ":t:r")
			local project_dir = vim.fn.fnamemodify(project_file, ":h")
			
			-- Build the project
			vim.notify("Building " .. project_name .. "...", vim.log.levels.INFO)
			local build_cmd = "dotnet build '" .. project_file .. "' --configuration Debug"
			local build_result = vim.fn.system(build_cmd)
			
			if vim.v.shell_error ~= 0 then
				vim.notify("Build failed:\n" .. build_result, vim.log.levels.ERROR)
				error("Build failed")
			end
			
			vim.notify("Build succeeded", vim.log.levels.INFO)
			
			-- Find DLL
			local dll_files = vim.fn.globpath(project_dir, "bin/*/**/" .. project_name .. ".dll", 0, 1)
			if not dll_files or #dll_files == 0 then
				vim.notify("DLL not found after build", vim.log.levels.ERROR)
				error("DLL not found")
			end
			
			local dll_path = vim.fn.fnamemodify(dll_files[1], ":p")
			vim.notify("Found DLL: " .. dll_path, vim.log.levels.INFO)
			return dll_path
		end

		-- C# Debug Configurations
		dap.configurations.cs = {
			{
				type = "coreclr",
				name = "Launch .NET Core",
				request = "launch",
				program = find_dll,
				cwd = "${workspaceFolder}",
				stopAtEntry = false,
				console = "internalConsole",
			},
			{
				type = "coreclr",
				name = "Attach to Process",
				request = "attach",
				processId = function()
					return require("dap.utils").pick_process({ filter = "dotnet" })
				end,
				justMyCode = false,
			},
		}

		-- Key mappings
		vim.keymap.set("n", "<leader>Dc", dap.continue, { desc = "Continue/Start Debug" })
		vim.keymap.set("n", "<leader>Db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>DB", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Conditional Breakpoint" })
		vim.keymap.set("n", "<leader>Di", dap.step_into, { desc = "Step Into" })
		vim.keymap.set("n", "<leader>Do", dap.step_over, { desc = "Step Over" })
		vim.keymap.set("n", "<leader>DO", dap.step_out, { desc = "Step Out" })
		vim.keymap.set("n", "<leader>Dt", dap.terminate, { desc = "Terminate Debugger" })
		vim.keymap.set("n", "<leader>Dr", dap.restart, { desc = "Restart Debugger" })
		vim.keymap.set("n", "<leader>Du", dapui.toggle, { desc = "Toggle Debug UI" })
		vim.keymap.set("n", "<leader>De", dapui.eval, { desc = "Evaluate Expression" })
		vim.keymap.set("v", "<leader>De", dapui.eval, { desc = "Evaluate Selection" })
	end,
}
