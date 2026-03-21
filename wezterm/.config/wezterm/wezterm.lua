local wezterm = require("wezterm")
local config = wezterm.config_builder()

---------------------------------------------------------------
-- THEME SELECTOR — change this to switch everything at once
---------------------------------------------------------------
local THEME = "catppuccin-mocha" -- "rose-pine" | "dracula" | "catppuccin-mocha"

local themes = {
  ["rose-pine"] = {
    color_scheme = "rose-pine",
    background = "#000000",
    tab_bar = {
      background = "#191724",
      active_tab = { bg_color = "#31748f", fg_color = "#e0def4", intensity = "Bold" },
      inactive_tab = { bg_color = "#1f1d2e", fg_color = "#6e6a86" },
      inactive_tab_hover = { bg_color = "#26233a", fg_color = "#ebbcba", italic = true },
      new_tab = { bg_color = "#1f1d2e", fg_color = "#6e6a86" },
      new_tab_hover = { bg_color = "#26233a", fg_color = "#9ccfd8", italic = true },
    },
  },
  ["dracula"] = {
    color_scheme = "Dracula (Official)",
    background = "#282A36",
    tab_bar = {
      background = "#21222c",
      active_tab = { bg_color = "#bd93f9", fg_color = "#282a36", intensity = "Bold" },
      inactive_tab = { bg_color = "#282a36", fg_color = "#6272a4" },
      inactive_tab_hover = { bg_color = "#44475a", fg_color = "#ff79c6", italic = true },
      new_tab = { bg_color = "#282a36", fg_color = "#6272a4" },
      new_tab_hover = { bg_color = "#44475a", fg_color = "#8be9fd", italic = true },
    },
  },
  ["catppuccin-mocha"] = {
    color_scheme = "Catppuccin Mocha",
    background = "#11111A",
    tab_bar = {
      background = "#11111b",
      active_tab = { bg_color = "#cba6f7", fg_color = "#1e1e2e", intensity = "Bold" },
      inactive_tab = { bg_color = "#181825", fg_color = "#6c7086" },
      inactive_tab_hover = { bg_color = "#313244", fg_color = "#f5c2e7", italic = true },
      new_tab = { bg_color = "#181825", fg_color = "#6c7086" },
      new_tab_hover = { bg_color = "#313244", fg_color = "#94e2d5", italic = true },
    },
  },
}

local t = themes[THEME]

---------------------------------------------------------------
-- appearance
---------------------------------------------------------------
-- font_dirs removed: wezterm searches all system font paths by default
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 17
config.color_scheme = t.color_scheme
config.window_background_opacity = 0.95
config.macos_window_background_blur = 10
config.window_padding = { left = 18, right = 15, top = 20, bottom = 5 }

config.max_fps = 120
config.animation_fps = 120
config.front_end = "WebGpu"
config.prefer_egl = true

config.enable_tab_bar = true
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.automatically_reload_config = true
config.audible_bell = "Disabled"
config.adjust_window_size_when_changing_font_size = false
config.harfbuzz_features = { "calt=0" }

-- apply theme colors
config.colors = {
  background = t.background,
  tab_bar = t.tab_bar,
}

local act = wezterm.action

---------------------------------------------------------------
-- keybindings (Cmd = primary, Cmd+Ctrl = secondary)
---------------------------------------------------------------
config.leader = { key = "Space", mods = "SUPER|OPT", timeout_milliseconds = 1000 }

config.keys = {
  -- panes: split
  { key = "\\", mods = "SUPER",      action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "\\", mods = "SUPER|OPT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- panes: navigate (vim-style)
  { key = "h", mods = "SUPER|OPT", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "SUPER|OPT", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "SUPER|OPT", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "SUPER|OPT", action = act.ActivatePaneDirection("Right") },

  -- panes: zoom + close
  { key = "Enter", mods = "SUPER",      action = act.TogglePaneZoomState },
  { key = "x",     mods = "SUPER",      action = act.CloseCurrentPane({ confirm = false }) },

  -- panes: resize (leader → h/j/k/l)
  { key = "p", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 1000 }) },

  -- panes: swap
  { key = "s", mods = "SUPER|OPT", action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActiveKeepFocus" }) },

  -- tabs: spawn + close
  { key = "t", mods = "SUPER",      action = act.SpawnTab("DefaultDomain") },
  { key = "x", mods = "SUPER|OPT", action = act.CloseCurrentTab({ confirm = false }) },

  -- tabs: navigate
  { key = "[", mods = "SUPER", action = act.ActivateTabRelative(-1) },
  { key = "]", mods = "SUPER", action = act.ActivateTabRelative(1) },

  -- tabs: move
  { key = "[", mods = "SUPER|OPT", action = act.MoveTabRelative(-1) },
  { key = "]", mods = "SUPER|OPT", action = act.MoveTabRelative(1) },

  -- scroll
  { key = "u", mods = "SUPER", action = act.ScrollByLine(-5) },
  { key = "d", mods = "SUPER", action = act.ScrollByLine(5) },

  -- misc
  { key = "f",     mods = "SUPER",  action = act.Search({ CaseInSensitiveString = "" }) },
  { key = "F11",   mods = "NONE",   action = act.ToggleFullScreen },
  { key = "F12",   mods = "NONE",   action = act.ShowDebugOverlay },
  { key = "n",     mods = "SUPER",  action = act.SpawnWindow },
}

config.key_tables = {
  resize_pane = {
    { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q",      action = "PopKeyTable" },
  },
}

config.mouse_bindings = {
  { event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.OpenLinkAtMouseCursor },
}

-- wezterm-tabs plugin
wezterm.plugin
  .require('https://github.com/yriveiro/wezterm-tabs')
  .apply_to_config(config, {
    tabs = {
      tab_bar_at_bottom = true,
      hide_tab_bar_if_only_one_tab = false,
      tab_max_width = 32,
    },
    
  })

return config
