return {
    'neovim/nvim-lspconfig',
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        'saghen/blink.cmp',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim'
    },

    config = function()
        local capabilities = require('blink.cmp').get_lsp_capabilities()
        local lspconfig = require('lspconfig')

        local function add_venv_to_pythonpath()
            local cwd = vim.fn.getcwd()
            local venv_path = cwd .. '/.venv'
            local python_version = vim.fn.systemlist(venv_path .. '/bin/python -c "import sys; print(f\'python{sys.version_info.major}.{sys.version_info.minor}\')"')[1]
            if python_version and python_version ~= '' then
                local site_packages = string.format("%s/lib/%s/site-packages", venv_path, python_version)
                local existing = vim.env.PYTHONPATH or ""
                if not string.find(existing, site_packages, 1, true) then
                    if existing ~= "" then
                        vim.env.PYTHONPATH = existing .. ":" .. site_packages
                    else
                        vim.env.PYTHONPATH = site_packages
                    end
                end
            end
        end

        local servers = {
            bashls = {},
            marksman = {},
            clangd = {},
            gopls = {},
            csharp_ls = {},

            pylsp = {
                on_new_config = function(new_config, _)
                    add_venv_to_pythonpath()
                end,
                settings = {
                    pylsp = {
                        plugins = {
                            jedi_completion = { enabled = true, fuzzy = true },
                            jedi_definition = { enabled = true },
                            jedi_hover = { enabled = true },
                            pyflakes = { enabled = false }, -- отключаем, чтобы не дублировать с ruff
                        }
                    }
                }
            },

            ruff = {},

            lua_ls = {},
        }

        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            "stylua",      -- форматтер Lua
            "prettierd",   -- форматтер JS/TS
        })
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        require("mason-lspconfig").setup({
            ensure_installed = {},
            automatic_installation = false,
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                    lspconfig[server_name].setup(server)
                end,
            },
        })
    end
}

