#!/bin/bash

CURRENT_DIR=$(cd -- "$( dirname -- "$0" )" && pwd)
DST_PATH=~/.config/yazi

if [[ ! -z $1 ]]; then
        DST_PATH=$1
fi

bash $CURRENT_DIR/../../.install/install.sh $CURRENT_DIR $DST_PATH
