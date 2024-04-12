local wezterm = require 'wezterm'

-- local scheme = wezterm.get_builtin_color_schemes()["Guezwhoz"]
-- local scheme = wezterm.get_builtin_color_schemes()["Hacktober"]
-- local scheme = wezterm.get_builtin_color_schemes()["kanagawabones"]
-- local scheme = wezterm.get_builtin_color_schemes()["Popping and Locking"]
-- local scheme = wezterm.get_builtin_color_schemes()["Doom Peacock"]
-- local scheme = wezterm.get_builtin_color_schemes()["Red Planet"]
local scheme = wezterm.get_builtin_color_schemes()["One Dark (Gogh)"]

scheme.background = "#16161d"
scheme.ansi[8] = "#dea050"
scheme.brights[8] = "#de9231"

-- No effect?
scheme.cursor_fg = "#8080c6"

return {
  color_schemes = { ["ConfiguredColors"] = scheme },
  color_scheme = "ConfiguredColors",
  -- window_background_opacity = 0.95,

  font_size = 24,
  font = wezterm.font_with_fallback({
    "Iosevka Term Custom",
    "0xProto",
    "Sudo",
    "Fantasque Sans Mono",
    "Ubuntu Mono",
    "Nimbus Mono PS",
    "Maple Mono",
    "Symbols Nerd Font",
    "NanumGothicCoding",
    "OpenMoji",
    "JoyPixels"
  }),
  harfbuzz_features = { 'kern', 'liga', 'clig', 'thnd', 'frac', 'txtr' },

  disable_default_key_bindings = true,
  keys = {
    { key = '=', mods = 'CTRL',       action = wezterm.action.IncreaseFontSize      },
    { key = '-', mods = 'CTRL',       action = wezterm.action.DecreaseFontSize      },
    { key = '0', mods = 'CTRL',       action = wezterm.action.ResetFontSize         },
    { key = 'v', mods = 'SHIFT|CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  },

  animation_fps = 30,
  default_cursor_style = "SteadyBar",
  canonicalize_pasted_newlines = "LineFeed",
  enable_tab_bar = false,

  check_for_updates = false,
}
