#!/bin/bash


function iterate_directory() {
        dir=$1
        cd $1
        for filename in *; do 
                if [[ -d $filename ]]; then
                        echo "$(iterate_directory $filename)"
                else 
                        echo "$(pwd)/$filename"
                fi
        done
}

echo "$(iterate_directory $1)"

