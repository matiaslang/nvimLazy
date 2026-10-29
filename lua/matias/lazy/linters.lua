return {
  "mfussenegger/nvim-lint",
  event = {
    "BufReadPre",
    "BufNewFile",
  },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint" },
      typescript = { "eslint" },
      javascriptreact = { "eslint" },
      typescriptreact = { "eslint" },
      svelte = { "eslint" },
      python = { "pylint" },
    }

    local eslint_configs = {
      ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
      ".eslintrc.yaml", ".eslintrc.yml", "eslint.config.js",
      "eslint.config.mjs", "eslint.config.cjs",
    }

    local function get_local_eslint()
      local dir = vim.fn.expand("%:p:h")
      for _, cfg in ipairs(eslint_configs) do
        if vim.fn.findfile(cfg, dir .. ";") ~= "" then
          local bin = vim.fn.findfile("node_modules/.bin/eslint", dir .. ";")
          if bin ~= "" then
            return vim.fn.fnamemodify(bin, ":p")
          end
        end
      end
      return nil
    end

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        local ft = vim.bo.filetype
        local eslint_fts = { javascript = true, typescript = true, javascriptreact = true, typescriptreact = true, svelte = true }
        if eslint_fts[ft] then
          local cmd = get_local_eslint()
          if not cmd then return end
          lint.linters.eslint.cmd = cmd
        end
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
