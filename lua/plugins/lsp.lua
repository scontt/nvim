return {
    'neovim/nvim-lspconfig',
    dependencies = { 
        { "williamboman/mason.nvim", opts = {} },
        'saghen/blink.cmp',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim'
    },

    opts = {
        servers = {
            lua_ls = {}
        }
    },
    config = function(_, opts)
        local lspconfig = require('lspconfig')
        for server, config in pairs(opts.servers) do
            config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
            lspconfig[server].setup(config)
        end
    end,

    config = function()
        local capabilities = require('blink.cmp').get_lsp_capabilities()
        local lspconfig = require('lspconfig')

        local servers = {
            bashls = {},
            marksman = {},
            clangd = {},
            -- gopls = {},
            pyright = {},
            -- rust_analyzer = {},
            -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
            --
            -- Some languages (like typescript) have entire language plugins that can be useful:
            --    https://github.com/pmizio/typescript-tools.nvim
            --
            -- But for many setups, the LSP (`ts_ls`) will work just fine
            -- ts_ls = {},
            --

            lua_ls = {
                -- cmd = { ... },
                -- filetypes = { ... },
                -- capabilities = {},
                -- settings = {
                    --   Lua = {
                        --     completion = {
                            --       callSnippet = 'Replace',
                            --     },
                            --     -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                            --     -- diagnostics = { disable = { 'missing-fields' } },
                            --   },
                            -- },
                        },
                    }

                    local ensure_installed = vim.tbl_keys(servers or {})
                    vim.list_extend(ensure_installed, {
                        "stylua", -- Used to format Lua code
                        "prettierd", -- Used to format javascript and typescript code
                    })
                    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

                    require("mason-lspconfig").setup({
                        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
                        automatic_installation = false,
                        handlers = {
                            function(server_name)
                                local server = servers[server_name] or {}
                                -- This handles overriding only values explicitly passed
                                -- by the server configuration above. Useful when disabling
                                -- certain features of an LSP (for example, turning off formatting for ts_ls)
                                server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                                require("lspconfig")[server_name].setup(server)
                            end,
                        },
                    })
                end
            }

