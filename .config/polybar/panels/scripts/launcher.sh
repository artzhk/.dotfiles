#!/usr/bin/env bash

DIR="$HOME/.config/polybar/panels/menu"

get_theme() {
    option=$(echo -e "light\ndark" \
            | rofi -no-config -no-lazy-grab -dmenu -format i:s \
             -theme "$DIR"/"$SYSTEM_THEME"/launcher.rasi)

    echo $option | sed 's/.*:\(.*\)/\1/'
}

theme=$(get_theme)

ln -sfn $HOME/.local/state/colorscheme/$theme.sh $HOME/.local/state/colorscheme/.system_theme

echo $theme
