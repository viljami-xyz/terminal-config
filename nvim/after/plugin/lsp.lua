local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
	"pyright",
	"ruff",
	"pylsp",
	"volar",
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
	["<C-y>"] = cmp.mapping.confirm({ select = true }),
	["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil

lsp.setup_nvim_cmp({
	mapping = cmp_mappings,
})

lsp.set_preferences({
	sign_icons = {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	},
})

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "gd", function()
		vim.lsp.buf.definition()
	end, opts)
	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover()
	end, opts)
	vim.keymap.set("n", "<leader>vws", function()
		vim.lsp.buf.workspace_symbol()
	end, opts)
	vim.keymap.set("n", "<leader>vd", function()
		vim.diagnostic.open_float()
	end, opts)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.goto_next()
	end, opts)
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.goto_prev()
	end, opts)
	vim.keymap.set("n", "<leader>vca", function()
		vim.lsp.buf.code_action()
	end, opts)
	vim.keymap.set("n", "<leader>vrr", function()
		vim.lsp.buf.references()
	end, opts)
	vim.keymap.set("n", "<leader>vrn", function()
		vim.lsp.buf.rename()
	end, opts)
	vim.keymap.set("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, opts)
end)

lsp.setup()

require("mason-null-ls").setup({
	ensure_installed = { "black", "vue-language-server@1.8.27" },
})

local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
null_ls.setup({
	sources = {
        --formatting.black,
		formatting.isort,
		formatting.stylua,
		formatting.prettierd.with({
			extra_args = { "--single-quote", "--print-width=88" },
		}),
	},
})

local lspconfig = require("lspconfig")

-- configure python server
lspconfig.pylsp.setup({
	settings = {
		pylsp = {
			plugins = {
				ruff = {
					enabled = true,
				},
				pycodestyle = {
					enabled = false,
				},
				pyflakes = {
					enabled = false,
				},
				mccabe = {
					enabled = false,
				},
				pyright = {
					enabled = false,
				},
			},
		},
	},
})

vim.keymap.set("n", "<leader>fmt", function()
	vim.lsp.buf.format({
		filter = function(client)
			return client.name ~= "tsserver" or client.name ~= "volar"
		end,
	})
end)

local autocmd_group = vim.api.nvim_create_augroup("Custom auto-commands", { clear = true })

--[[
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.py" },
	desc = "Auto format python files",
	callback = function()
		local fileName = vim.api.nvim_buf_get_name(0)
		vim.cmd(":silent !ruff format " .. fileName)
	end,
	group = autocmd_group,
})
--]]

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.vue" },
	desc = "Auto format Vue files",
	callback = function()
		local fileName = vim.api.nvim_buf_get_name(0)
		vim.cmd([[:Prettier]])
		-- Save file
		vim.cmd([[:w]])
	end,
	group = autocmd_group,
})

vim.diagnostic.config({
	virtual_text = true,
})

vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
})
