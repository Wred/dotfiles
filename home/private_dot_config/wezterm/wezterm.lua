-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux

-- This table will hol the configuration.
local config = wezterm.config_builder()

config.use_ime = false
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 13
config.enable_tab_bar = false
config.scrollback_lines = 10000

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

-- and finally, return the configuration to wezterm
return config
