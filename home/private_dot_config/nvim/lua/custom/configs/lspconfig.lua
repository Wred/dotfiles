local config = require("plugins.configs.lspconfig")
local config_on_attach = config.on_attach
local capabilities = config.capabilities

local lspconfig = require("lspconfig")

lspconfig.rust_analyzer.setup({
  on_attach = config_on_attach,
  capabilities = capabilities,
  filetypes = {"rust"},
  root_dir = lspconfig.util.root_pattern("Cargo.toml")
})

lspconfig.tsserver.setup({
  on_attach = function (client)
    client.server_capabilities.documentFormattingProvider = false
    return config_on_attach(client)
  end,
  capabilities = capabilities,
  init_options = {
    preferences = {
      disableSuggestions = true,
    }
  },
})

lspconfig.gopls.setup ({
  on_attach = config_on_attach,
  capabilities = capabilities,
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
