-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hol the configuration.
local config = wezterm.config_builder()

config.use_ime = false
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 15
config.enable_tab_bar = false
config.scrollback_lines = 10000

config.window_close_confirmation = 'NeverPrompt'

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  local gui_window = window:gui_window();
  gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
end)

config.max_fps = 120
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- and finally, return the configuration to wezterm
return config
