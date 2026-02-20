#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/vim/vim /work/vim
cd /work/vim/src

./configure \
	--with-wayland \
       	--enable-python3interp=yes \
       	--enable-pythoninterp=yes \
       	--enable-fail-if-missing \
       	--disable-darwin \
       	--enable-luainterp=yes \
       	--enable-rubyinterp=yes \
       	--enable-tclinterp=yes \
       	--enable-perlinterp=yes \
       	--enable-cscope \
       	--enable-terminal \
       	--enable-multibyte \
       	--disable-rightleft \
       	--disable-arabic \
       	--enable-xim \
       	--enable-gpm=yes \
       	--enable-wayland-focus-steal

make -j 
make -j install
