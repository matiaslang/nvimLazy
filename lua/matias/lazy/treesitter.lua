return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local parsers = {
      "c", "lua", "vim", "vimdoc", "elixir", "javascript", "html", "python", "typescript",
      "markdown", "markdown_inline",
    }
    local filetypes = {
      "c", "lua", "vim", "help", "elixir", "javascript", "html", "python", "typescript",
      "markdown",
    }

    require("nvim-treesitter").install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetypes,
      callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldlevel = 99
      end,
    })
  end
}
