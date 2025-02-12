-- Adapted from a combo of
-- https://lsp-zero.netlify.app/v3.x/blog/theprimeagens-config-from-2022.html
-- https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/lazy/lsp.lua
return {
    "neovim/nvim-lspconfig",
dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
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
            lsp_zero.default_keymaps({buffer = bufnr})

            vim.keymap.set("n", "gd", function () vim.lsp.buf.definition() end, opts)
            vim.keymap.set("n", "K", function () vim.lsp.buf.hover() end, opts)
            vim.keymap.set("n", "vca", function () vim.lsp.buf.code_action() end, opts)
            vim.keymap.set("n", "vrr", function () vim.lsp.buf.references() end, opts)
            vim.keymap.set("n", "vrn", function () vim.lsp.buf.rename() end, opts)
        end)



        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        require("fidget").setup({})
        require("mason").setup()

        require('mason-lspconfig').setup({
            ensure_installed = {
                "angularls",
                "unocss",
                "gopls",
                "ast_grep",
                "eslint",
                "jsonls",
                "somesass_ls",
                "svelte",
                "yamlls",
                "lua_ls",
                "ruff",
            },
            handlers = {
                function(server_name)
                    require('lspconfig')[server_name].setup({
                        capabilities = capabilities,
                    })
                end,
                lua_ls = function()
                    require('lspconfig').lua_ls.setup({
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = {
                                    version = 'LuaJIT'
                                },
                                diagnostics = {
                                    globals = { 'vim', 'love' },
                                },
                                workspace = {
                                    library = {
                                        vim.env.VIMRUNTIME,
                                    }
                                }
                            }
                        }
                    })
                end
            }
        })

        local cmp = require('cmp')
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        -- this is the function that loads the extra snippets to luasnip
        -- from rafamadriz/friendly-snippets
        require('luasnip.loaders.from_vscode').lazy_load()

        cmp.setup({
            sources = {
                { name = 'copilot' },
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'luasnip', keyword_length = 2 },
                { name = 'buffer',  keyword_length = 3 },
            },
            mapping = cmp.mapping.preset.insert({
                -- ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                -- ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                -- ['<C-Space>'] = cmp.mapping.complete(),
            }),
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
        })
    end
}
