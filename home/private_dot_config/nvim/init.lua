vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")
dofile(vim.g.base46_cache .. "syntax")
dofile(vim.g.base46_cache .. "treesitter")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Andre customizations
vim.opt.colorcolumn = "80"
vim.opt.autoindent = true
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = 0
vim.opt.linebreak = true

vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set({ "i", "x", "n", "s" }, "<C-q>", "<cmd>qa<cr>", { desc = "Quit" })
vim.wo.relativenumber = true

vim.lsp.enable({
	"rust_analyzer",
	"ts_ls",
	"gopls",
	"golangci_lint_ls",
	"ruff",
	"pyright",
	"jsonls",
	"yamlls",
	"helm_ls",
	"prismals",
})

-- Helm: use gotmpl treesitter parser for helm filetype
vim.treesitter.language.register("gotmpl", "helm")

-- Helm: register filetype for Helm chart templates
vim.filetype.add({
	extension = { tpl = "helm" },
	pattern = {
		[".*/templates/.*%.yaml"] = "helm",
		[".*/templates/.*%.tpl"] = "helm",
		["helmfile.*%.yaml"] = "helm",
	},
})

-- Prevent yamlls from attaching to helm buffers (Go templates break yaml parsing)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "yamlls" and vim.bo[args.buf].filetype == "helm" then
			vim.lsp.buf_detach_client(args.buf, args.data.client_id)
		end
	end,
})
