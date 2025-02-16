#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Launcher (Modi Drun, Run, File Browser, Window)
#
## Available Styles

dir="$HOME/.config/rofi/launchers/type-1"

source $HOME/.local/state/colorscheme/.system_theme
system_theme=$SYSTEM_THEME

if [[ ! -e "$dir/$system_theme.rasi" ]]; then
        system_theme="light"
fi

echo $system_theme

if [[ "$2" == "--window" || "$1" == "--window" ]]; then
        rofi \
                -show window \
                -theme ${dir}/${system_theme}.rasi
        exit 2
fi

rofi \
        -show drun \
        -theme ${dir}/${system_theme}.rasi
