local connection_id = "string"
local server_url = "sting"

local filetypes = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"python",
	"go",
	"cs",
	"java",
	"html",
	"xml",
	"php",
}

local function read_file(path)
	if vim.fn.filereadable(path) == 0 then
		return nil
	end
	return table.concat(vim.fn.readfile(path), "\n")
end

local function yaml_value(text, key)
	return text:match(key .. ":%s*'([^']+)'") or text:match(key .. ':%s*"([^"]+)"')
end

local function path_has(path, segment)
	return path:find(segment .. "/", 1, true) ~= nil or path:sub(-#segment) == segment
end

local function find_binding(start)
	local dir = start
	while dir and dir ~= "" and dir ~= "/" do
		local vscode = read_file(dir .. "/.vscode/settings.json")
		if vscode and vscode:find("sonarlint%.connectedMode%.project", 1) then
			local key = vscode:match('"projectKey"%s*:%s*"([^"]+)"')
			if key then
				return key, vscode:match('"connectionId"%s*:%s*"([^"]+)"')
			end
		end

		local props = read_file(dir .. "/sonar-project.properties")
		if props then
			local key = props:match("sonar%.projectKey%s*=%s*(%S+)")
			if key then
				return key, nil
			end
		end

		local connected = read_file(dir .. "/.sonarlint/connectedMode.json")
		if connected then
			local key = connected:match('"projectKey"%s*:%s*"([^"]+)"')
			if key then
				return key, connected:match('"connectionId"%s*:%s*"([^"]+)"')
			end
		end

		local pipeline = read_file(dir .. "/infra/devops/pipeline.yml")
		if pipeline then
			local backend = yaml_value(pipeline, "sonarqubeProjectKeyForBackend")
			local frontend = yaml_value(pipeline, "sonarqubeProjectKeyForFrontend")
			if backend and path_has(start, "/src/backend") then
				return backend, nil
			end
			if frontend and path_has(start, "/src/frontend") then
				return frontend, nil
			end
		end

		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			break
		end
		dir = parent
	end
end

local cached_token

local function sonar_token()
	if cached_token and cached_token ~= "" then
		return cached_token
	end

	for _, name in ipairs({ "SONARQUBE_TOKEN", "SONAR_TOKEN" }) do
		local value = vim.fn.getenv(name)
		if type(value) == "string" and value ~= "" then
			cached_token = value
			return value
		end
	end

	if vim.fn.executable("security") == 1 then
		local account = server_url:match("^https://(.+)$") or server_url:match("^http://(.+)$") or server_url
		local output = vim.fn.system({
			"security",
			"find-generic-password",
			"-s",
			"sonarqube-cli",
			"-a",
			account,
			"-w",
		})
		if vim.v.shell_error == 0 then
			cached_token = vim.trim(output)
			if cached_token ~= "" then
				return cached_token
			end
		end
	end
end

local function java_executable()
	local home = vim.fn.getenv("JAVA_HOME")
	local candidates = {
		"/opt/homebrew/opt/openjdk@21/bin/java",
		"/opt/homebrew/opt/openjdk@17/bin/java",
		"/opt/homebrew/opt/openjdk/bin/java",
		"/usr/local/opt/openjdk@21/bin/java",
		"/usr/local/opt/openjdk@17/bin/java",
	}
	if type(home) == "string" and home ~= "" then
		table.insert(candidates, 1, home .. "/bin/java")
	end
	for _, path in ipairs(candidates) do
		if path and vim.fn.executable(path) == 1 then
			return path
		end
	end

	if vim.fn.executable("java") == 1 then
		vim.fn.system({ "java", "-version" })
		if vim.v.shell_error == 0 then
			return "java"
		end
	end
end

local function analyzer_jars(dir)
	local jars = {}
	if vim.fn.isdirectory(dir) == 0 then
		return jars
	end
	for name, typ in vim.fs.dir(dir) do
		local lower = name:lower()
		local skip = lower:find("cfamily", 1, true) or lower:find("cpp", 1, true)
		-- Mason publishes these jars as symlinks. vim.fs.dir reports those as
		-- "link", so a "file"-only check finds nothing and the server never starts.
		local path = dir .. "/" .. name
		if
			(typ == "file" or typ == "link")
			and name:sub(-4) == ".jar"
			and not skip
			and vim.fn.filereadable(path) == 1
		then
			jars[#jars + 1] = path
		end
	end
	table.sort(jars)
	return jars
end

local function sonarlint_cmd(dispatchers)
	local java = java_executable()
	if not java then
		error("SonarQube needs JDK 17 or newer. Install it with: brew install openjdk@21")
	end

	local mason = vim.fn.stdpath("data") .. "/mason"
	local jar = mason .. "/packages/sonarlint-language-server/extension/server/sonarlint-ls.jar"
	if vim.fn.filereadable(jar) == 0 then
		error("sonarlint-language-server is not installed yet. Open :Mason and wait for it, then reopen the file.")
	end

	local analyzers = analyzer_jars(mason .. "/share/sonarlint-analyzers")
	if #analyzers == 0 then
		error("SonarQube analyzers were not found under Mason. Reinstall sonarlint-language-server.")
	end

	local cmd = { java, "-jar", jar, "-stdio", "-analyzers" }
	vim.list_extend(cmd, analyzers)
	return vim.lsp.rpc.start(cmd, dispatchers)
end

return {
	"https://gitlab.com/schrieveslaach/sonarlint.nvim",
	ft = filetypes,
	dependencies = {
		"neovim/nvim-lspconfig",
		"williamboman/mason.nvim",
	},
	config = function()
		local mason = vim.fn.stdpath("data") .. "/mason"
		local init_options = {
			showVerboseLogs = false,
		}
		local omnisharp = mason .. "/packages/sonarlint-language-server/extension/omnisharp"
		local csharp = mason .. "/share/sonarlint-analyzers/sonarcsharp.jar"
		if vim.fn.isdirectory(omnisharp) == 1 then
			init_options.omnisharpDirectory = omnisharp
		end
		if vim.fn.filereadable(csharp) == 1 then
			init_options.csharpOssPath = csharp
		end
		local enterprise = mason .. "/share/sonarlint-analyzers/csharpenterprise.jar"
		if vim.fn.filereadable(enterprise) == 1 then
			init_options.csharpEnterprisePath = enterprise
		end

		require("sonarlint").setup({
			filetypes = filetypes,
			connected = {
				get_credentials = function()
					return sonar_token()
				end,
			},
			server = {
				cmd = sonarlint_cmd,
				init_options = init_options,
				settings = {
					sonarlint = {
						automaticAnalysis = true,
						focusOnNewCode = false,
						connectedMode = {
							connections = {
								sonarqube = {
									{
										connectionId = connection_id,
										serverUrl = server_url,
										disableNotifications = false,
									},
								},
								-- Empty table: the plugin indexes this on every connection check.
								sonarcloud = {},
							},
						},
					},
				},
				before_init = function(_, config)
					local bufname = vim.api.nvim_buf_get_name(0)
					local start = bufname ~= "" and vim.fn.fnamemodify(bufname, ":p:h") or vim.fn.getcwd()
					local key, id = find_binding(start)
					if not key then
						vim.notify_once(
							"SonarQube: no project key in this repo. Add sonar.projectKey to sonar-project.properties, or sonarlint.connectedMode.project to .vscode/settings.json.",
							vim.log.levels.WARN
						)
						return
					end
					config.settings.sonarlint.connectedMode.project = {
						connectionId = id or connection_id,
						projectKey = key,
					}
				end,
			},
		})

		-- Frontend and backend are different Sonar projects in one git repo.
		-- The language server starts once per repo, so switch the bound project
		-- when the buffer moves between them.
		vim.api.nvim_create_autocmd("BufEnter", {
			callback = function(args)
				if not vim.tbl_contains(filetypes, vim.bo[args.buf].filetype) then
					return
				end
				local bufname = vim.api.nvim_buf_get_name(args.buf)
				if bufname == "" then
					return
				end
				local key, id = find_binding(vim.fn.fnamemodify(bufname, ":p:h"))
				if not key then
					return
				end
				local connection = id or connection_id
				for _, client in ipairs(vim.lsp.get_clients({ name = "sonarlint.nvim", bufnr = args.buf })) do
					local connected = client.settings
						and client.settings.sonarlint
						and client.settings.sonarlint.connectedMode
					if connected then
						local project = connected.project or {}
						if project.projectKey ~= key or project.connectionId ~= connection then
							connected.project = { connectionId = connection, projectKey = key }
							if client.initialized then
								client:notify("workspace/didChangeConfiguration", { settings = {} })
							end
						end
					end
				end
			end,
		})

		local ft = vim.bo.filetype
		if vim.tbl_contains(filetypes, ft) then
			-- Lazy loads this plugin from a FileType event. Replaying that event
			-- synchronously is ignored while the original callback is running,
			-- so defer it until Lazy's handler has returned.
			vim.schedule(function()
				vim.api.nvim_exec_autocmds("FileType", { buffer = vim.api.nvim_get_current_buf() })
			end)
		end
	end,
}
