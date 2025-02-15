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
  filetypes = { "go", "gomod" },
  cmd = {'golangci-lint-langserver'},
  root_dir = lspconfig.util.root_pattern('.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json', 'go.work', 'go.mod', '.git'),
  init_options = {
    command = { "golangci-lint", "run", "--out-format", "json" };
  }
})

lspconfig.biome.setup({})

