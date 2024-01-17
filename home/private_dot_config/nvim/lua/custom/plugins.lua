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
      'williamboman/mason.nvim',
      opts = {
        registries = {
          'github:nvim-java/mason-registry',
          'github:mason-org/mason-registry',
        },
      },
    },
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
}
return plugins
