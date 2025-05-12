-- Mason setup to install LSP servers
require("mason").setup()

-- Set up Mason for LSP config
require("mason-lspconfig").setup({
    ensure_installed = {
        "pyright", -- Python language server
        "pylsp", -- Python LSP server
        "volar", -- Vue.js LSP server
    },
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup({})
        end,
    },
})

-- LSP Zero setup
local lsp_zero = require("lsp-zero")

-- Attach function for setting up LSP key mappings
lsp_zero.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end)

-- nvim-cmp setup
local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = {
    ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
    ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
}

lsp_zero.setup({
    cmp = {
        mapping = cmp_mappings,
    },
    preferences = {
        sign_icons = {
            error = "E",
            warn = "W",
            hint = "H",
            info = "I",
        },
    },
})

-- Optional: Configure pylsp specifically
require("lspconfig").pylsp.setup({
    settings = {
        pylsp = {
            plugins = {
                ruff = { enabled = true },
                pycodestyle = { enabled = false },
                pyflakes = { enabled = false },
                mccabe = { enabled = false },
                pyright = { enabled = false },
            },
        },
    },
})

-- Setup null-ls for formatters
local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting

null_ls.setup({
    sources = {
        formatting.isort,
        formatting.stylua,
        formatting.prettierd.with({
            extra_args = { "--single-quote", "--print-width=88" },
        }),
    },
})

-- Auto commands
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "*.vue" },
    callback = function()
        vim.cmd("Prettier")
        vim.cmd("write")
    end,
    group = vim.api.nvim_create_augroup("AutoFormat", { clear = true }),
})

-- Diagnostics config
vim.diagnostic.config({
    virtual_text = true,
})

-- Optional: format shortcut
vim.keymap.set("n", "<leader>fmt", function()
    vim.lsp.buf.format({
        filter = function(client)
            return client.name ~= "tsserver" and client.name ~= "volar"
        end,
    })
end)

-- Copilot remap
vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false,
})

