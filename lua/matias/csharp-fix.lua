-- Fix for csharp.nvim dotnet-cli shell escaping issue
-- The plugin doesn't properly quote launch profile names with spaces/parentheses

local M = {}

function M.setup()
	-- Get access to the original dotnet-cli module
	local dotnet_cli = require("csharp.modules.dotnet-cli")
	local logger = require("csharp.log")

	-- Override the problematic run function
	local original_run = dotnet_cli.run

	dotnet_cli.run = function(options)
		local command = "dotnet run"

		if options then
			-- Process each option and properly quote ones that need it
			local processed_options = {}
			local i = 1
			while i <= #options do
				local opt = options[i]

				-- If this is --launch-profile, the next argument needs to be quoted
				if opt == "--launch-profile" and i < #options then
					table.insert(processed_options, opt)
					i = i + 1
					local profile_name = options[i]
					-- Always quote the profile name to handle spaces and special chars
					table.insert(processed_options, vim.fn.shellescape(profile_name))
				else
					-- For other options, add them as-is (they're usually fine)
					table.insert(processed_options, opt)
				end
				i = i + 1
			end
			command = command .. " " .. table.concat(processed_options, " ")
		end

		logger.debug("Executing (fixed): " .. command, { feature = "dotnet-cli" })

		local current_window = vim.api.nvim_get_current_win()
		vim.cmd("split | term " .. command)
		vim.api.nvim_set_current_win(current_window)
	end
end

return M
