#!/bin/bash

theme=$1

echo $theme

if [[ $theme != "--light" && $theme != "--dark" ]]; then 
        echo "Invalid set terminal scheme argument.\nPlease use --light or --dark"
        exit 1
fi

if [[ $theme == "--light" ]]; then 
        ln -sfn $PWD/.config/alacritty/themes/art_kanagawa.toml $PWD/.config/alacritty/themes/colorscheme
fi

if [[ $theme == "--dark" ]]; then 
        ln -sfn $PWD/.config/alacritty/themes/art.toml $PWD/.config/alacritty/themes/colorscheme
fi

