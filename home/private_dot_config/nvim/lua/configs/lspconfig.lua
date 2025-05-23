-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()
local nvlsp = require "nvchad.configs.lspconfig"
local lspconfig = require "lspconfig"

lspconfig.rust_analyzer.setup({
	on_attach = nvlsp.on_attach,
	capabilities = nvlsp.capabilities,
	filetypes = {"rust"},
	root_dir = lspconfig.util.root_pattern("Cargo.toml")
})

lspconfig.ts_ls.setup({
	on_attach = function (client)
		client.server_capabilities.documentFormattingProvider = false
		return nvlsp.config_on_attach(client)
	end,
	capabilities = nvlsp.capabilities,
	init_options = {
		preferences = {
			disableSuggestions = true,
		}
	},
})

lspconfig.gopls.setup ({
	on_attach = nvlsp.on_attach,
	capabilities = nvlsp.capabilities,
	cmd = {"gopls"},
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
		},
	},
})

lspconfig.golangci_lint_ls.setup ({
	on_attach = nvlsp.on_attach,
	capabilities = nvlsp.capabilities,
	cmd = {'golangci-lint-langserver'},
	filetypes = { "go", "gomod" },
	root_dir = lspconfig.util.root_pattern('.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json', 'go.work', 'go.mod', '.git'),
	init_options = {
		command = { 'golangci-lint', 'run', '--output.json.path=stdout', '--show-stats=false' };
	}
})

lspconfig.ruff.setup ({
	on_attach = nvlsp.on_attach,
	capabilities = nvlsp.capabilities,
	cmd = { 'ruff', 'server' },
	filetypes = { 'python' },
	root_dir = lspconfig.util.root_pattern('pyproject.toml', 'ruff.toml', '.ruff.toml', '.git'),
	single_file_support = true,
	settings = {},
})

-- https://github.com/astral-sh/ruff-lsp/issues/23
lspconfig.pyright.setup ({
	on_attach = nvlsp.on_attach,
	capabilities = nvlsp.capabilities,
	cmd = { 'pyright-langserver', '--stdio' },
	filetypes = { 'python' },
	root_dir = lspconfig.util.root_pattern('pyproject.toml', 'ruff.toml', '.ruff.toml', '.git'),
	single_file_support = true,
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "off",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "off",
				autoImportCompletions = false,
			},
			linting = {
				enabled = false,
            }
		}
	},
})

lspconfig.jsonls.setup({
	on_attach = nvlsp.on_attach,
	capabilities = nvlsp.capabilities,
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    init_options = {
      provideFormatter = true,
    },
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
    end,
    single_file_support = true,
	settings = {
		json = {
			schemas = require('schemastore').json.schemas(),
			validate = { enable = true },
		},
	},
})


lspconfig.yamlls.setup({
	on_attach = nvlsp.on_attach,
	capabilities = nvlsp.capabilities,
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
    end,
    single_file_support = true,
	settings = {
		-- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
		redhat = { telemetry = { enabled = false } },
		yaml = {
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- this plugin and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = "",
			},
			schemas = require('schemastore').yaml.schemas(),
		},
	},
})

lspconfig.prismals.setup({
    cmd = { 'prisma-language-server', '--stdio' },
    filetypes = { 'prisma' },
    settings = {
      prisma = {
        prismaFmtBinPath = '',
      },
    },
    root_dir = lspconfig.util.root_pattern('.git', 'package.json'),
  })
