
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
        android ) os="android"; break;;
    esac
done

echo "You selected $os"

echo "${GREEN}Updating dotfiles for $os... ${NC}"

cp -v ~/.dotfiles/.tmux.conf ~/
cp -v ~/.dotfiles/.vimrc ~/
if [[ $os != "android" ]]; then
    cp -vr ~/.dotfiles/alacritty ~/.config/
fi
mkdir -p ~/.oh-my-zsh/themes && 
    cp -vr ~/.dotfiles/.oh-my-zsh/themes ~/.oh-my-zsh/
mkdir -p ~/.local/scripts/ && 
    cp -v ~/.dotfiles/scripts/* ~/.local/scripts/

if [[ $os == "macos" ]]; then 
    cp -v ~/.dotfiles/macos/.bashrc ~/
    cp -v ~/.dotfiles/macos/.bash_profile ~/
    cp -v ~/.dotfiles/macos/.zshrc ~/
fi 

if [[ $os == "archlinux" ]] ; then
    cp -v ~/.dotfiles/linux/clipton ~/.config/
    cp -v ~/.dotfiles/linux/.bashrc ~/
    cp -v ~/.dotfiles/linux/.bash_profile ~/
    cp -v ~/.dotfiles/linux/.zshrc ~/
    cp -vr ~/.dotfiles/linux/polybar ~/.config/
    cp -v ~/.dotfiles/linux/.xinitrc ~/
    cp -v ~/.dotfiles/linux/.Xresources ~/
    cp -vr ~/.dotfiles/linux/bat ~/.config/
    cp -vr ~/.dotfiles/linux/kitty ~/.config/
    cp -vr ~/.dotfiles/linux/rofi ~/.config/
    cp -vr ~/.dotfiles/linux/spicetify/Themes/text/color.ini ~/.config/spicetify/Themes/text/
    cp -vr ~/.dotfiles/linux/yazi ~/.config/
    cp -vr ~/.dotfiles/linux/i3 ~/.config/
fi





