#!/usr/bin/env bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "${GREEN}Updating local files... ${NC}"
echo "${GREEN}Copying get_diff_and_copy function... ${NC}"

cp -v ~/.dotfiles/scripts/* ~/.local/scripts/

os=$1

# Create a menu to select the OS archlinux either macos
echo "Select the OS you are using: "

select os in "archlinux" "macos"; do
    case $os in
        archlinux ) os="archlinux"; break ;;
        macos ) os="macos"; break ;;
        android ) os="android"; break ;;
    esac
done

echo "You selected $os"

echo "${GREEN}Updating dotfiles for $os... ${NC}"

get_diff_and_copy ~/.dotfiles/.tmux.conf ~/
mkdir -p ~/.local/scripts/

if [[ $os != "android" ]]; then
    get_diff_and_copy ~/.dotfiles/alacritty ~/.config/
fi


if [[ $os == "android" ]]; then
    get_diff_and_copy ~/.dotfiles/macos/.tmux.conf.local ~/
fi

if [[ $os == "macos" ]]; then
    mkdir -p ~/.oh-my-zsh/themes
    cp -vr ~/.dotfiles/.oh-my-zsh/themes ~/.oh-my-zsh/
    get_diff_and_copy ~/.dotfiles/macos/.bashrc ~/
    get_diff_and_copy ~/.dotfiles/macos/.bash_profile ~/
    get_diff_and_copy ~/.dotfiles/macos/.zshrc ~/
fi

if [[ $os == "archlinux" ]] ; then
    cp -vr ~/.dotfiles/linux/clipton ~/.config/
    get_diff_and_copy ~/.dotfiles/linux/.bashrc ~/
    get_diff_and_copy ~/.dotfiles/linux/.bash_profile ~/
    get_diff_and_copy ~/.dotfiles/linux/.zshrc ~/
    cp -vr ~/.dotfiles/linux/polybar ~/.config/
    get_diff_and_copy ~/.dotfiles/linux/.xinitrc ~/
    get_diff_and_copy ~/.dotfiles/linux/.Xresources ~/
    cp -vr ~/.dotfiles/linux/bat ~/.config/
    cp -vr ~/.dotfiles/linux/kitty ~/.config/
    cp -vr ~/.dotfiles/linux/rofi ~/.config/
    get_diff_and_copy ~/.dotfiles/linux/spicetify/Themes/text/color.ini ~/.config/spicetify/Themes/text/
    cp -vr ~/.dotfiles/linux/yazi ~/.config/
    cp -vr ~/.dotfiles/linux/i3 ~/.config/
fi





