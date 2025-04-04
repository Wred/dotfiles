return {
	{
		"sphamba/smear-cursor.nvim",
		event = "VeryLazy",
		opts = {
			-- Smear cursor when switching buffers or windows.
			smear_between_buffers = true,

			-- Smear cursor when moving within line or to neighbor lines.
			-- Use `min_horizontal_distance_smear` and `min_vertical_distance_smear` for finer control
			smear_between_neighbor_lines = true,

			-- Draw the smear in buffer space instead of screen space when scrolling
			scroll_buffer_space = true,

			-- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
			-- Smears will blend better on all backgrounds.
			legacy_computing_symbols_support = false,

			-- Smear cursor in insert mode.
			-- See also `vertical_bar_cursor_insert_mode` and `distance_stop_animating_vertical_bar`.
			smear_insert_mode = true,
		},
	},
	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		opts = {
			duration_multiplier = 0.6,
			easing = 'cubic',
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		opts ={
			view = {
				side = "right",
				width = 60,
			}
		},
	},

	{
		"nvim-tree/nvim-web-devicons",
		lazy = true
	},

	{
		"nvchad/ui",
		lazy = false,
		config = function ()
			require "nvchad"
		end,
	},

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			dashboard = { enabled = true },
			notifier = {
				enabled = true,
				timeout = 3000,
			},
			quickfile = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			styles = {
				notification = {
					wo = { wrap = true } -- Wrap notifications
				}
			}
		},
		keys = {
			{ "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
			{ "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
			{ "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
			{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
			{ "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
			{ "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
			{ "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
			{ "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
			{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
			{ "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
			{ "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
			{ "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
			{ "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
			{ "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
			{ "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
			{
				"<leader>N",
				desc = "Neovim News",
				function()
					Snacks.win({
						file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
						width = 0.6,
						height = 0.6,
						wo = {
							spell = false,
							wrap = false,
							signcolumn = "yes",
							statuscolumn = " ",
							conceallevel = 3,
						},
					})
				end,
			}
		},
		init = function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				callback = function()
					-- Setup some globals for debugging (lazy-loaded)
					_G.dd = function(...)
						Snacks.debug.inspect(...)
					end
					_G.bt = function()
						Snacks.debug.backtrace()
					end
					vim.print = _G.dd -- Override print to use snacks for `:=` command

					-- Create some toggle mappings
					Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
					Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
					Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
					Snacks.toggle.diagnostics():map("<leader>ud")
					Snacks.toggle.line_number():map("<leader>ul")
					Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
					Snacks.toggle.treesitter():map("<leader>uT")
					Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
					Snacks.toggle.inlay_hints():map("<leader>uh")
				end,
			})
		end,
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
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"lua-language-server",
				"gopls",
				"golangci-lint-langserver",
				"rust-analyzer",
				"typescript-language-server",
				"ruff",
				"pyright",
				"jsonls",
				"yamlls",
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
			require "configs.lspconfig"
		end,
	},

	{
		"b0o/schemastore.nvim",
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = function()
			local options = require "nvchad.configs.treesitter"
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
		---@type gopher.Config
		opts = {},
	},

	{
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

	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- set this if you want to always pull the latest change
		opts = {
			-- add any opts here
			provider = "azure",
			azure = {
				endpoint = "https://platformx.openai.azure.com",
				deployment = "PlatformX-GPT4o",
				api_version = "2024-08-01-preview",
			},
			behaviour = {
				auto_apply_diff_after_generation = true,
			},
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				'MeanderingProgrammer/render-markdown.nvim',
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},

	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},

	{
		"stevearc/conform.nvim",
		-- event = 'BufWritePre', -- uncomment for format on save
		opts = require "configs.conform",
	},
}
