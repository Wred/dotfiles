local plugins = {
  'nvim-java/nvim-java',
  dependencies = {
    'nvim-java/lua-async-await',
    'nvim-java/nvim-java-core',
    'nvim-java/nvim-java-test',
    'nvim-java/nvim-java-dap',
    'MunifTanjim/nui.nvim',
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-dap',
    {
      "williamboman/mason-lspconfig.nvim",
      opts = {
        handlers = {
          ["jdtls"] = function()
            require("java").setup()
          end,
        },
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        find_files = {
          hidden = true
        }
      }
    }
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "gopls",
        "rust-analyzer",
        "python-lsp-server",
        "typescript-language-server",
        "biome",
        "json-lsp",
      },
      registries = {
        'github:nvim-java/mason-registry',
        'github:mason-org/mason-registry',
      },
     },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls").builtins
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.formatting.biome,

        -- or if you like to live dangerously like me:
        nls.formatting.biome.with({
          args = {
            'check',
            '--apply-unsafe',
            '--formatter-enabled=true',
            '--organize-imports-enabled=true',
            '--skip-errors',
            '$FILENAME',
          },
        }),
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      local options = require "plugins.configs.treesitter"
      options.ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "java",
        "python",
        "rust",
        "go",
        "json",
        "make",
      }
      return options
    end,
  },
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    -- branch = "develop", -- if you want develop branch
    -- keep in mind, it might break everything
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap", -- (optional) only if you use `gopher.dap`
    },
    -- (optional) will update plugin's deps on every update
    build = function()
      vim.cmd.GoInstallDeps()
    end,
    ---@type gopher.Config
    opts = {},
  },
  {
    "nvim-pack/nvim-spectre",
    lazy = false,
    config = function()
      require('spectre').setup({ is_block_ui_break = true })
    end,
  },
  {
      'kevinhwang91/nvim-hlslens',
    config = function ()
      require("hlslens").setup()
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    lazy = false,
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'kevinhwang91/nvim-hlslens',
    },
    config = function ()
      require("scrollbar").setup()
    end,
  },
}
return plugins
