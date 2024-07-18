#!/usr/bin/env bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

os=$1

# Create a menu to select the OS archlinux either macos
echo "Select the OS you are using: "

select os in "archlinux" "macos"; do
    case $os in
        archlinux ) os="archlinux"; break;;
        macos ) os="macos"; break;;
    esac
done

echo "You selected $os"

echo "${GREEN}Uploading dotfiles from $os... ${NC}"

cp -vf ~/.tmux.conf ~/.dotfiles/
cp -vf ~/.vimrc ~/.dotfiles/
cp -vfr ~/.config/alacritty ~/.dotfiles/
mkdir -p ~/.dotfiles/.oh-my-zsh/ && cp -vfr ~/.oh-my-zsh/themes ~/.dotfiles/.oh-my-zsh/
mkdir -p ~/.dotfiles/scripts/ && cp -vf ~/.local/scripts/* ~/.dotfiles/scripts/

if [[ $os == "macos" ]]; then 
    cp -vf ~/.bashrc ~/.dotfiles/macos/
    cp -vf ~/.bash_profile ~/.dotfiles/macos/
    cp -vf ~/.zshrc ~/.dotfiles/macos/
fi 

if [[ $os == "archlinux" ]] ; then
    cp -vf ~/.bashrc ~/.dotfiles/linux/
    cp -vf ~/.bash_profile ~/.dotfiles/linux/
    cp -vf ~/.zshrc ~/.dotfiles/linux/
    cp -vfr ~/.config/polybar ~/.dotfiles/linux/
    cp -vf ~/.xinitrc ~/.dotfiles/linux/
    cp -vf ~/.Xresources ~/.dotfiles/linux/
    cp -vfr ~/.config/bat ~/.dotfiles/linux/
    cp -vfr ~/.config/kitty ~/.dotfiles/linux/
    cp -vfr ~/.config/rofi ~/.dotfiles/linux/
    mkdir ~/.dotfiles/linux/spicetify/Themes/text/ -p && cp -vfr ~/.config/spicetify/Themes/text/color.ini ~/.dotfiles/linux/spicetify/Themes/text/
    cp -vfr ~/.config/yazi ~/.dotfiles/linux/
    cp -vfr ~/.config/i3 ~/.dotfiles/linux/
fi


