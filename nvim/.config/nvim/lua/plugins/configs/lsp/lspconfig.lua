--  This function gets run when an LSP connects to a particular buffer.
local on_attach = require("mappings.lspmappings").on_attach

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem = {
-- 	documentationFormat = { "markdown", "plaintext" },
-- 	snippetSupport = true,
-- 	preselectSupport = true,
-- 	insertReplaceSupport = true,
-- 	labelDetailsSuppot = true,
-- 	deprecatedSupport = true,
-- 	commitCharactersSupport = true,
-- 	tagSupport = {
-- 		valueSet = { 1 },
-- 	},
-- 	resolveSupport = {
-- 		properties = { "documentation", "detail", "additionalTextEdits" },
-- 	},
-- }

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
-- so that auto-suggestion-from LSP appers on cmp-nvim.
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers below are installed
local servers_list = {
	-- clangd = {},
	-- html = {},
	-- cssls = {},
	-- gopls = {},
	-- rust_analyzer = {},
	-- javascrip servers...
	-- denols = {},
	tsserver = {},
	-- python servers..
	pyright = require("plugins.configs.lsp.LspServerSettings.pyright"),
	-- lua servers ...
	lua_ls = require("plugins.configs.lsp.LspServerSettings.lua_ls"),
}

---------------------Adding Mason (order is important) -----------------------
-- Setup mason so it can manage external tooling
require("mason").setup(require("plugins.configs.lsp.mason"))

-- other formatters to instlal for null-ls with :MasonInstallAll command
local formatters_linters_servers = {
	"prettier",
	"stylua", -- "deno",
	"ruff",
	"mypy",
	"black",
}

vim.api.nvim_create_user_command("MasonInstallAll", function()
	vim.cmd("MasonInstall " .. table.concat(formatters_linters_servers, " "))
end, {})

vim.g.mason_binaries_list = formatters_linters_servers
------------------------------------------------------------------------------

-- TODO: check what is does.
require("neodev").setup()

-- Manage LSP server using mason_lspconfig.
local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers_list),
	automatic_installation = true,
})

-- looping through all the servers by setup_handlers.
mason_lspconfig.setup_handlers({
	function(server_name)
		lspconfig[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers_list[server_name],
		})
	end,
})

--------------- diagnostic, viwes -----------------
local opts = {
	diagnostics = {
		underline = true,
		update_in_insert = false,
		virtual_text = {
			spacing = 4,
			source = "if_many",
			--prefix = "●",
			-- prefix `icons` will set set the prefix to a function that returns the diagnostics icon based on the severity
			-- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
			prefix = "icons",
		},
		severity_sort = true,
	},
}

for name, icon in pairs(require("utils.icons_lazynvim").icons.diagnostics) do
	name = "DiagnosticSign" .. name
	vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
end
if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
	opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
		or function(diagnostic)
			local icons = require("utils.icons_lazynvim").icons.diagnostics
			for d, icon in pairs(icons) do
				if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
					return icon
				end
			end
		end
end
vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
