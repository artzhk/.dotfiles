#
#!/usr/bin/env bash
#

GREEN="\e[32m"
NC="\e[0m" # No color

echo "${GREEN}Installing essentials...${NC}"

ln -svfn ~/.dotfiles/.tmux.conf ~/.tmux.conf

bash ~/.dotfiles/scripts/install.sh

# os=$1
# 
# # Create a menu to select the OS archlinux either macos
# echo "Select the OS you are using: "
# 
# select os in "archlinux" "macos"; do
#     case $os in
#         archlinux ) os="archlinux"; break ;;
#         macos ) os="macos"; break ;;
#         android ) os="android"; break ;;
#     esac
# done
# 
# echo "You selected $os"

# TODO: Create per folder script that copies all the files to the appropriate locations


