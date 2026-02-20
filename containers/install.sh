#!/usr/bin/env bash

set -oue pipefail

GREEN="\e[32m"
BOLD="\e[1m"
BLUE="\e[34m"
NC="\e[0m" # No color

install() {
	distro=$1
	containername="vim_build"
	imagename="vim-wayland"

	docker build -t $imagename $distro/.
	docker run --name $containername $imagename

	mkdir $distro/build
	docker cp $containername:/work/vim/src/vim $distro/build/vim
	docker cp $containername:/usr/local/share/vim $distro/build/vimdir

	docker rm $containername
	docker image remove $imagename

	echo -e "${BOLD}${BLUE} === Vim compiled successfully === ${NC}"
}

install $1
