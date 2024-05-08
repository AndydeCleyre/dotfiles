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

scheme.background = "#16161d"
scheme.ansi[8] = "#dea050"
scheme.brights[8] = "#de9231"
scheme.cursor_bg = "#ff8bf0"
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
    "Iosevka Term Custom Extended",
    "Iosevka Term Custom",
    "0xProto",
    "Sudo",
    "Fantasque Sans Mono",
    "Ubuntu Mono",
    "Maple Mono",
    "Symbols Nerd Font",
    "NanumGothicCoding",
    "SerenityOS Emoji",
    "OpenMoji Color",
    "JoyPixels",
  }),
  font_rules = {
    {
      intensity = "Bold",
      italic = true,
      font = wezterm.font {
        family = "0xProto",
        weight = "Bold",
        style = "Italic",
      }
    },
    {
      italic = true,
      font = wezterm.font {
        family = "0xProto",
        style = "Italic",
      }
    }
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
