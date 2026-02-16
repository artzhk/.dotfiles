#!/usr/bin/env bash
set -euo pipefail

RED="\e[31m"
GREEN="\e[32m"
BOLD="\e[1m"
BLUE="\e[34m"
NC="\e[0m" # No color

declare -A BLACKLIST=(
	[install.sh]=1
	[Makefile]=1
	[.config]=1
	[.local]=1
	[bash]=1
	[containers]=1
	[.git]=1
	[.install]=1
	[.emacs.d]=1
	[packages-lists]=1
	[vim]=1
	[X11]=1
	[etc]=1
)

install() {
        local src_folder="${1:-}"
        local target_folder="${2:-}"
        local mode="${3:-ln}"

        if [[ -z "$src_folder" ]]; then
                src_folder=$( cd -- "$( dirname -- "$0" )" && pwd )
                echo -e "Source directory detected ${BOLD}${GREEN} $src_folder ${NC}"
        fi

        if [[ -z "$target_folder" ]]; then
                echo -e "${BOLD}${RED}No target folder provided${NC}"
                return 1
        fi

        echo -e "\n${GREEN}-> Installing with ${BOLD}$mode${NC}${GREEN} dots from${NC} ${BOLD}${BLUE}$src_folder${NC}${GREEN} to ${NC}${BOLD}${BLUE}$target_folder${NC}"

        if [[ ! -d "$target_folder" ]]; then
                echo -e "${BOLD}${GREEN}Creating target folder $target_folder${NC}"
                mkdir -p "$target_folder"
        fi

        for f in "$src_folder"/* "$src_folder"/.*; do
                local i="$(basename "$f")"
                [[ "$i" == "." || "$i" == ".." || ${BLACKLIST[$i]+x} ]] && continue
                if [[ "$mode" == "cp" ]]; then
                        cp -vr "$src_folder/$i" "$target_folder/$i"
                elif [[ "$mode" == "ln" ]]; then
                        ln -vsfn "$src_folder/$i" "$target_folder/$i"
                else
                        echo -e "${BOLD}${RED}Unknown mode: $mode (expected 'ln' or 'cp')${NC}"
                        return 1
                fi
        done
}

install "$@"
