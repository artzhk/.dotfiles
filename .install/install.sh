#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
BOLD="\e[1m"
NC="\e[0m" # No color


function install() {
        src_folder=$1
        target_folder=$2
        mode=$3

        if [[ -z $1 ]]; then 
                src_folder=$( cd -- "$( dirname -- "$0" )" && pwd )
                echo -e "Source directory detected ${BOLD}${GREEN} $src_folder ${NC}"
        fi 

        if [[ -z $2 ]]; then
                echo -e "${BOLD}${RED}No target folder provided${NC}"
        fi

        echo -e "${GREEN}-> Installing with ${BOLD}$mode${NC}${GREEN} dots from${NC} ${BOLD}${BLUE}$src_folder${NC}${GREEN} to ${NC}${BOLD}${BLUE}$target_folder${NC}\n"

        if [[ ! -d $target_folder ]]; then 
                mkdir -p $target_folder
        fi 

        for i in $(ls -a $src_folder); do 
                if [[ "$i" != "install.sh" && "$i" != "." && "$i" != ".." ]]; then
                       if [[ "$mode" == "cp" ]]; then 
                               cp -vr $src_folder/$i $target_folder/$i
                       else
                               if [[ ! -d "$src_folder/$i" ]]; then
                                       ln -vsfn $src_folder/$i $target_folder/$i
                               fi 
                       fi 
                fi
        done
}

install $1 $2 $3
