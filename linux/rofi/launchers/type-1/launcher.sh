#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Launcher (Modi Drun, Run, File Browser, Window)
#
## Available Styles
#
## style-1     style-2     style-3     style-4     style-5
## style-6     style-7     style-8     style-9     style-10
## style-11    style-12    style-13    style-14    style-15

dir="$HOME/.config/rofi/launchers/type-1"
system_theme="$SYSTEM_THEME"

if [ ! -e "$dir/$system_theme.rasi" ]; then
    system_theme="dark"
fi

if [[ "$1" == "--window" ]]; then
    rofi \
        -show window \
        -theme ${dir}/${system_theme}.rasi
    exit 2
fi

rofi \
    -show drun \
    -theme ${dir}/${system_theme}.rasi
