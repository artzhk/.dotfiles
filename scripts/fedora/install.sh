#!/bin/bash

function install() {
        target_folder=~/.local/scripts
        src_folder=~/.dotfiles/scripts/fedora

        if [[ ! -z $1 ]]; then 
                target_folder=$1
        fi 

        if [[ ! -d $target_folder ]]; then 
                mkdir -p $target_folder
        fi 

        for i in $(ls -a $src_folder); do 
                if [[ ! -d "$i" && "$i" != "install.sh" ]]; then
                        ln -vsfn $src_folder/$i $target_folder/$i
                fi
        done
}

install $1
