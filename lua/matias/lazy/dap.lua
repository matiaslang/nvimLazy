return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

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

		-- Key mappings for debugging (using <leader>D* to avoid conflicts)
		vim.keymap.set("n", "<leader>Db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>DB", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Conditional Breakpoint" })
		vim.keymap.set("n", "<leader>Dc", dap.continue, { desc = "Continue/Start Debug" })
		vim.keymap.set("n", "<leader>Di", dap.step_into, { desc = "Step Into" })
		vim.keymap.set("n", "<leader>Do", dap.step_over, { desc = "Step Over" })
		vim.keymap.set("n", "<leader>DO", dap.step_out, { desc = "Step Out" })
		vim.keymap.set("n", "<leader>Dr", dap.restart, { desc = "Restart Debugger" })
		vim.keymap.set("n", "<leader>Dt", dap.terminate, { desc = "Terminate Debugger" })
		vim.keymap.set("n", "<leader>Du", dapui.toggle, { desc = "Toggle Debug UI" })
		vim.keymap.set("n", "<leader>De", dapui.eval, { desc = "Evaluate Expression" })
		vim.keymap.set("v", "<leader>De", dapui.eval, { desc = "Evaluate Selection" })
		vim.keymap.set("n", "<leader>Dl", dap.run_last, { desc = "Run Last Debug Session" })

		-- C# DAP Configuration
		dap.adapters.coreclr = {
			type = "executable",
			command = vim.fn.expand("~/.local/share/nvim/mason/bin/netcoredbg"),
			args = { "--interpreter=vscode" },
		}

		-- Helper function to build and get DLL path
		local function get_dll_path(env_name)
			return function()
				print("Starting C# debug (" .. env_name .. ")...")

				-- Find main project
				local cwd = vim.fn.getcwd()
				local csproj_files = vim.fn.globpath(cwd, "**/*.csproj", 0, 1)

				if #csproj_files == 0 then
					print("No .csproj files found")
					return nil
				end

				local main_projects = {}
				for _, proj in ipairs(csproj_files) do
					if not string.match(proj:lower(), "test") then
						table.insert(main_projects, proj)
					end
				end

				local projects = #main_projects > 0 and main_projects or csproj_files
				local selected_project = projects[1]
				local project_name = vim.fn.fnamemodify(selected_project, ":t:r")

				-- Build the project
				print("Building " .. project_name .. " for " .. env_name .. "...")
				local build_cmd = "dotnet build '" .. selected_project .. "' --configuration Debug"
				local build_result = vim.fn.system(build_cmd)
				if vim.v.shell_error ~= 0 then
					print("Build failed: " .. build_result)
					return nil
				end

				-- Find DLL
				local project_dir = vim.fn.fnamemodify(selected_project, ":h")
				local dll_files = vim.fn.globpath(project_dir, "bin/Debug/**/" .. project_name .. ".dll", 0, 1)

				if #dll_files > 0 then
					print("Using DLL: " .. dll_files[1])
					return dll_files[1]
				else
					print("No DLL found for " .. project_name)
					return nil
				end
			end
		end

		-- Helper function to get project directory
		local function get_project_dir()
			local cwd = vim.fn.getcwd()
			local csproj_files = vim.fn.globpath(cwd, "**/*.csproj", 0, 1)
			if #csproj_files > 0 then
				local main_projects = {}
				for _, proj in ipairs(csproj_files) do
					if not string.match(proj:lower(), "test") then
						table.insert(main_projects, proj)
					end
				end
				local projects = #main_projects > 0 and main_projects or csproj_files
				return vim.fn.fnamemodify(projects[1], ":h")
			end
			return cwd
		end

		dap.configurations.cs = {
			{
				type = "coreclr",
				name = "Debug: Local Environment",
				request = "launch",
				program = get_dll_path("Local"),
				cwd = get_project_dir,
				stopAtEntry = false,
				env = {
					ASPNETCORE_ENVIRONMENT = "Local",
				},
			},
			{
				type = "coreclr",
				name = "Debug: LocalCosmos Environment",
				request = "launch",
				program = get_dll_path("LocalCosmos"),
				cwd = get_project_dir,
				stopAtEntry = false,
				env = {
					ASPNETCORE_ENVIRONMENT = "LocalCosmos",
				},
			},
			{
				type = "coreclr",
				name = "Debug: LocalCI Environment",
				request = "launch",
				program = get_dll_path("LocalCI"),
				cwd = get_project_dir,
				stopAtEntry = false,
				env = {
					ASPNETCORE_ENVIRONMENT = "LocalCI",
				},
			},
			{
				type = "coreclr",
				name = "Attach to Process",
				request = "attach",
				processId = function()
					return require("dap.utils").pick_process({ filter = "dotnet" })
				end,
			},
		}

		-- Key mappings for DAP UI elements
		vim.keymap.set("n", "<leader>Ds", function()
			dapui.toggle({ layout = 1 })
		end, { desc = "Toggle Debug Sidebar" })
		vim.keymap.set("n", "<leader>Dp", function()
			dapui.toggle({ layout = 2 })
		end, { desc = "Toggle Debug Panel" })
	end,
}
