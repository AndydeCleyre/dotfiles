local wezterm = require "wezterm"

local scheme_bases = {
  "One Dark (Gogh)",
  "kanagawabones",
  "Popping and Locking",
  "Doom Peacock",
  "Red Planet",
}
local scheme_base = scheme_bases[math.random(1, #scheme_bases)]
local scheme = wezterm.get_builtin_color_schemes()[scheme_base]

scheme.background = "#1e201f"
scheme.ansi[8] = "#e29997"
scheme.brights[8] = "#ff7e7a"
scheme.cursor_bg = "#f69c9b"
return {
  color_schemes = { ["ConfiguredColors"] = scheme },
  color_scheme = "ConfiguredColors",

  window_background_opacity = 1.0,
  default_cursor_style = "SteadyBar",
  animation_fps = 30,
  canonicalize_pasted_newlines = "LineFeed",
  check_for_updates = false,
  disable_default_key_bindings = true,
  enable_tab_bar = false,

  font_size = 24,
  font = wezterm.font_with_fallback({
    "Iosevka Term Custom",
    "Iosevka Term Custom SmEx",
    "Iosevka Term Custom Extended",
    "0xProto",
    "Sudo",
    "Fantasque Sans Mono",
    "Ubuntu Mono",
    "LXGW WenKai Mono TC",
    "Maple Mono",
    "Symbols Nerd Font",
    "NanumGothicCoding",
    "Twemoji",
    "SerenityOS Emoji",
    "OpenMoji Color",
    "JoyPixels",
  }),
  font_rules = {
  },
  harfbuzz_features = {
    "clig",
    "frac",
    "kern",
    "liga",
    "thnd",
    "txtr",
  },

  keys = {
    { key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    { key = "v", mods = "SHIFT|CTRL", action = wezterm.action.PasteFrom "Clipboard" },
  },
}
