---@type Wezterm
local wezterm = require "wezterm"

-- A helper function for my fallback fonts
local function font_with_fallback(name, params)
 local names = { name, "mini-file-icons", "Hack Nerd Font", "SauceCodePro Nerd Font" }
 return wezterm.font_with_fallback(names, params)
end

local config = wezterm.config_builder()
config.term = "wezterm"
-- More speed
config.front_end = "WebGpu"
-- ALL the speed
config.webgpu_power_preference = "HighPerformance"
config.cursor_thickness = 2
config.default_cursor_style = 'SteadyBar'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.line_height = 1.2
config.cell_width = 0.9
config.tab_bar_at_bottom = true
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "RESIZE"
config.audible_bell = "Disabled"
config.hide_tab_bar_if_only_one_tab = true
config.use_dead_keys = false
config.selection_word_boundary = " \t\n{}[]()\"'`,;:@"
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
config.window_background_opacity = 0.70
config.macos_window_background_blur = 100
config.underline_position = -6
config.underline_thickness = '210%'
config.font = font_with_fallback {
  family = "FiraCode Nerd Font",
  harfbuzz_features = {
   "zero",
  },
 }
config.font_rules = {
  {
   intensity = "Bold",
   font = font_with_fallback {
    family = "Liga SFMono Nerd Font",
    harfbuzz_features = {
     "zero",
    },
    weight = "Medium",
   },
  },
  {
   italic = true,
   intensity = "Bold",
   font = font_with_fallback {
    family = "Iosevka Nerd Font",
    -- family = "Dank Mono",
    weight = "Medium",
    italic = true,
   },
  },
  {
   italic = true,
   font = font_with_fallback {
    -- family = "Dank Mono",
    family = "Iosevka Nerd Font",
    weight = "Regular",
    italic = true,
   },
  },
 }
return config --[[@as Wezterm]]
