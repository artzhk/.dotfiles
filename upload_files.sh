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

cp -v ~/.tmux.conf ~/.dotfiles/
cp -v ~/.vimrc ~/.dotfiles/
cp -vr ~/.config/alacritty ~/.dotfiles/
mkdir -p ~/.dotfiles/.oh-my-zsh/ && cp -vr ~/.oh-my-zsh/themes ~/.dotfiles/.oh-my-zsh/
mkdir -p ~/.dotfiles/scripts/ && cp -v ~/.local/scripts/* ~/.dotfiles/scripts/

if [[ $os == "macos" ]]; then 
    cp -v ~/.bashrc ~/.dotfiles/macos/
    cp -v ~/.bash_profile ~/.dotfiles/macos/
    cp -v ~/.zshrc ~/.dotfiles/macos/
fi 

if [[ $os == "archlinux" ]] ; then
    cp -v ~/.config/clipton ~/.dotfiles/linux/
    cp -v /usr/local/share/fonts/ttf/* ~/.dotfiles/fonts/
    cp -v ~/.bashrc ~/.dotfiles/linux/
    cp -v ~/.bash_profile ~/.dotfiles/linux/
    cp -v ~/.zshrc ~/.dotfiles/linux/
    cp -vr ~/.config/polybar ~/.dotfiles/linux/
    cp -v ~/.xinitrc ~/.dotfiles/linux/
    cp -v ~/.Xresources ~/.dotfiles/linux/
    cp -vr ~/.config/bat ~/.dotfiles/linux/
    cp -vr ~/.config/kitty ~/.dotfiles/linux/
    cp -vr ~/.config/rofi ~/.dotfiles/linux/
    mkdir ~/.dotfiles/linux/spicetify/Themes/text/ -p && cp -vr ~/.config/spicetify/Themes/text/color.ini ~/.dotfiles/linux/spicetify/Themes/text/
    cp -vr ~/.config/yazi ~/.dotfiles/linux/
    cp -vr ~/.config/i3 ~/.dotfiles/linux/
fi


