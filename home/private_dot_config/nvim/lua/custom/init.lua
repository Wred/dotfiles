vim.opt.colorcolumn = "80"

vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set({ "i", "x", "n", "s" }, "<C-q>", "<cmd>qa<cr>", { desc = "Quit" })

vim.wo.relativenumber = true

