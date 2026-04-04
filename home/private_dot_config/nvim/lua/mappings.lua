require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Unified navigation: vim splits -> tmux panes -> hyprland windows
local function nav(dir)
  local winnr = vim.fn.winnr()
  vim.cmd("wincmd " .. dir)
  if vim.fn.winnr() == winnr then
    local dirs = { h = "left", j = "down", k = "up", l = "right" }
    vim.fn.jobstart("nav-pane.sh " .. dirs[dir])
  end
end

map("n", "<A-h>", function() nav("h") end, { desc = "Navigate left" })
map("n", "<A-j>", function() nav("j") end, { desc = "Navigate down" })
map("n", "<A-k>", function() nav("k") end, { desc = "Navigate up" })
map("n", "<A-l>", function() nav("l") end, { desc = "Navigate right" })
