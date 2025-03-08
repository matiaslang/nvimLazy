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
    },
    config = function()
        local cmp_lsp = require("cmp_nvim_lsp")
        local lsp_zero = require("lsp-zero")

        lsp_zero.on_attach(function(client, bufnr)
            local opts = { buffer = bufnr, remap = false }
            lsp_zero.default_keymaps({ buffer = bufnr })

            vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
            vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
            vim.keymap.set("n", "vca", function() vim.lsp.buf.code_action() end, opts)
            vim.keymap.set("n", "vrr", function() vim.lsp.buf.references() end, opts)
            vim.keymap.set("n", "vrn", function() vim.lsp.buf.rename() end, opts)
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
                "prettier",
                "stylua",
                "eslint_d",
                "pylint"
            }
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
                    require('lspconfig').lua_ls.setup(lua_opts)
                end,
            },
            -- capabilities = capabilities
        })

        local languageServerPath =
        "/Users/matiaslang/.nvm/versions/node/v20.11.0/lib/node_modules/@angular/language-server/"
        local cmd = { "ngserver", "--stdio", "--tsProbeLocations", languageServerPath, "--ngProbeLocations",
            languageServerPath }

        -- require'lspconfig'.angularls.setup({
        --     -- on_attach = on_attach,
        --     capabilities = capabilities,
        --     cmd = cmd,
        --     on_new_config = function(new_config, new_root_dir)
        --         new_config.cmd = cmd
        --     end,
        -- })

        require 'lspconfig'.angularls.setup {}



        -- Setup nvim-cmp
        local cmp = require('cmp')
        cmp.setup({
            sources = {
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'nvim_lua' },
                { name = 'luasnip' },
                { name = 'buffer' },
            },
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
        })
    end
}
