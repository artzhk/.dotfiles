local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'Rosé Pine Dawn (Gogh)'
--config.color_scheme = 'Rosé Pine (Gogh)'

config.force_reverse_video_cursor = true
config.hide_tab_bar_if_only_one_tab = true

config.font = wezterm.font_with_fallback {
  {
    family = 'Ubuntu Mono',
    weight = 'Regular',
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  },
}

return config
