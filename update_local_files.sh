
# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

if [[ $os != "android" ]]; then
    get_diff_and_copy ~/.dotfiles/alacritty ~/.config/
fi

mkdir -p ~/.oh-my-zsh/themes
get_diff_and_copy ~/.dotfiles/.oh-my-zsh/themes ~/.oh-my-zsh/
mkdir -p ~/.local/scripts/
get_diff_and_copy ~/.dotfiles/scripts/* ~/.local/scripts/

if [[ $os == "macos" ]]; then
    get_diff_and_copy ~/.dotfiles/macos/.bashrc ~/
    get_diff_and_copy ~/.dotfiles/macos/.bash_profile ~/
    get_diff_and_copy ~/.dotfiles/macos/.zshrc ~/
    get_diff_and_copy ~/.dotfiles/macos/aerospace ~/.config/
fi

if [[ $os == "archlinux" ]] ; then
    get_diff_and_copy ~/.dotfiles/linux/clipton ~/.config/
    get_diff_and_copy ~/.dotfiles/linux/.bashrc ~/
    get_diff_and_copy ~/.dotfiles/linux/.bash_profile ~/
    get_diff_and_copy ~/.dotfiles/linux/.zshrc ~/
    get_diff_and_copy ~/.dotfiles/linux/polybar ~/.config/
    get_diff_and_copy ~/.dotfiles/linux/.xinitrc ~/
    get_diff_and_copy ~/.dotfiles/linux/.Xresources ~/
    get_diff_and_copy ~/.dotfiles/linux/bat ~/.config/
    get_diff_and_copy ~/.dotfiles/linux/kitty ~/.config/
    get_diff_and_copy ~/.dotfiles/linux/rofi ~/.config/
    get_diff_and_copy ~/.dotfiles/linux/spicetify/Themes/text/color.ini ~/.config/spicetify/Themes/text/
    get_diff_and_copy ~/.dotfiles/linux/yazi ~/.config/
    get_diff_and_copy ~/.dotfiles/linux/i3 ~/.config/
fi





