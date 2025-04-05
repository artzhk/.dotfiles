#!/bin/bash

theme=$1

echo $theme

if [[ $theme != "--light" && $theme != "--dark" ]]; then 
        echo "Invalid set terminal scheme argument.\nPlease use --light or --dark"
        exit 1
fi

if [[ $theme == "--light" ]]; then 
        ln -sfn $HOME/.config/alacritty/themes/art_kanagawa.toml $HOME/.config/alacritty/themes/colorscheme
fi

if [[ $theme == "--dark" ]]; then 
        ln -sfn $HOME/.config/alacritty/themes/art.toml $HOME/.config/alacritty/themes/colorscheme
fi

