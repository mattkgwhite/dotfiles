local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 11.0

-- Theme
config.color_scheme = "Catppuccin Mocha"

-- Window
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Cursor
config.default_cursor_style = "SteadyBlock"

-- Scrollback
config.scrollback_lines = 10000000

-- Mouse
config.hide_mouse_cursor_when_typing = true

-- Kitty graphics protocol
config.enable_kitty_graphics = true

-- Copy on select
config.selection_word_boundary = " \t\n{}[]()\"'`,;:@"

-- Default to PowerShell 7 on Windows
if wezterm.target_triple:find("windows") then
  config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- Tab bar at the bottom, retro style to keep it minimal
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- tmux-style keybindings (C-a leader, matching oh-my-tmux config)
local act = wezterm.action

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },

  -- Pane splits (oh-my-tmux + stock tmux bindings)
  { key = "-", mods = "LEADER",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "_", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "%", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- Pane navigation (hjkl, no repeat — matching tmux rebind)
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- Pane zoom / close
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

  -- Window (tab) management
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

  -- Direct tab select (prefix + 0-9)
  { key = "0", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "1", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(2) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(3) },
  { key = "4", mods = "LEADER", action = act.ActivateTab(4) },
  { key = "5", mods = "LEADER", action = act.ActivateTab(5) },
  { key = "6", mods = "LEADER", action = act.ActivateTab(6) },
  { key = "7", mods = "LEADER", action = act.ActivateTab(7) },
  { key = "8", mods = "LEADER", action = act.ActivateTab(8) },
  { key = "9", mods = "LEADER", action = act.ActivateTab(9) },

  -- Pane select (prefix + q in tmux shows pane numbers)
  { key = "q", mods = "LEADER", action = act.PaneSelect },

  -- Copy mode (prefix + [ in tmux)
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

  -- Rename tab (prefix + , in tmux)
  { key = ",", mods = "LEADER", action = act.PromptInputLine({
    description = "Tab name:",
    action = wezterm.action_callback(function(window, _, line)
      if line then window:active_tab():set_title(line) end
    end),
  }) },
}

return config
