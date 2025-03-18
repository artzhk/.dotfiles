#!/bin/bash

function install() {
        target_folder=~/.local/scripts
        src_folder=~/.dotfiles/scripts

        if [[ + -z $1 ]]; then 
                src_folder=$1
        fi 

        if [[ + -z $2 ]]; then 
                src_folder=$2
        fi 

        if [[ ! -d $target_folder ]]; then 
                mkdir -p $target_folder
        fi 

        for i in $(ls -a $src_folder); do 
                if [[ "$i" != "install.sh" ]]; then
                        ln -vsfn $src_folder/$i $target_folder/$i
                fi
        done
}

install $1 $2
