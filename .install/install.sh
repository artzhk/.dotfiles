#!/usr/bin/env bash
set -euo pipefail

RED="\e[31m"
GREEN="\e[32m"
BOLD="\e[1m"
BLUE="\e[34m"
NC="\e[0m" # No color

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
                [[ "$i" == "." || "$i" == ".." || "$i" == "install.sh" || "$i" == "Makefile" ]] && continue
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
