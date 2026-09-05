SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

SRC ?= $(HOME)/.dotfiles
DST ?= $(HOME)
MODE ?= ln

TPM_DIR := $(DST)/.tmux/plugins/tpm
VIM_PLUG := $(DST)/.vim/autoload/plug.vim
INSTALL_SH := $(SRC)/.install/install.sh

.PHONY: help install install-default vim-dirs tmux-plugins vim-plug link-root link-configs link-local link-emacs build-vim profile-wayland profile-wayland-tiling profile-x11 profile-x11-tiling xorg-conf

help:
	@echo "usage:"
	@echo "  make <target> [SRC=...] [DST=...] [MODE=ln|cp]"
	@echo ""
	@echo "variables:"
	@echo "  SRC   dotfiles source dir (default: $(HOME)/.dotfiles)"
	@echo "  DST   destination home dir to install into (default: $(HOME))"
	@echo "  MODE  how .config entries are installed via .install/install.sh (default: ln)"
	@echo "        ln = symlink   cp = copy"
	@echo ""
	@echo "targets:"
	@echo "  help            show this help"
	@echo "  install         full install: vim dirs, tmux tpm, vim-plug, link root, link .config/*"
	@echo "                  uses SRC/DST/MODE"
	@echo "  install-default same as 'install' with SRC=$(HOME)/.dotfiles DST=$(HOME) MODE=ln"
	@echo "  vim-dirs        create \$$DST/.vim/{undo,backup,swap}"
	@echo "  tmux-plugins    install tmux tpm into \$$DST/.tmux/plugins/tpm if missing"
	@echo "  vim-plug        install vim-plug into \$$DST/.vim/autoload/plug.vim"
	@echo "  link-root       run .install/install.sh for SRC -> DST (root-level dotfiles)"
	@echo "  link-configs    for each entry in \$$SRC/.config starting with [A-Za-z],"
	@echo "                  run .install/install.sh SRC/.config/<name> -> DST/.config/<name> using MODE"
	@echo "  link-local      for each entry in \$$SRC/.local starting with [A-Za-z],"
	@echo "                  run .install/install.sh SRC/.local/<name> -> DST/.local/<name> using MODE"
	@echo "  link-emacs      run .install/install.sh for SRC/.emacs.d -> DST/.emacs.d using MODE"
	@echo "  build-vim       Arch Linux x86_64 only: build vim in ./containers/arch-amd64 then"
	@echo "                  copy vim -> /usr/local/vim and runtime -> /usr/local/share/vim/"
	@echo "  tty-keymap      dvorak-programmer keyboard with escape instead of ctrl linked to /usr/share/kbd/keymaps/i386/dvorak/custom.map"
	@echo "  profile-wayland session profile: labwc, stacking (+waybar). installs those"
	@echo "                  .config entries using MODE, removes \$$DST/.xinitrc"
	@echo "  profile-wayland-tiling"
	@echo "                  session profile: sway (+waybar)"
	@echo "  profile-x11     session profile: openbox, stacking (+tint2). installs those"
	@echo "                  .config entries, links .Xresources and .xinitrc"
	@echo "  profile-x11-tiling"
	@echo "                  session profile: i3"
	@echo "  xorg-conf       sudo-install X11/xorg.conf to /etc/X11/xorg.conf (shared by both"
	@echo "                  x11 profiles, nvidia+intel specific to that laptop, so opt-in)"
	@echo ""
	@echo "examples:"
	@echo "  make install"
	@echo "  make install DST=/tmp/home"
	@echo "  make install SRC=$$PWD DST=$$HOME MODE=cp"
	@echo "  make build-vim"

install: vim-dirs tmux-plugins vim-plug link-root link-configs link-local link-emacs
	@echo "dotfiles installed: SRC=$(SRC) DST=$(DST) MODE=$(MODE)"

install-default:
	@$(MAKE) install SRC="$(HOME)/.dotfiles" DST="$(HOME)" MODE="ln"

#https://unix.stackexchange.com/questions/709302/how-to-remap-ctrl-to-caps-lock-in-a-tty
tty-keymap: 
	@echo "==> checking kernel version"
	@set -euo pipefail; \
	if [[ "$$(uname -v)" == *"Debian"* ]] || [[ "$$(uname -v)" == *"Ubuntu"* ]]; then \
		echo "    Detected $$(uname -v)"; \
		echo "    See keyboard(5) to modify console language settings" >&2; \
		exit 1; \
	fi;
	@echo "==> Sudo access reqired to link dvorak-programmer custom keymap to /usr/share/kbd/keymaps/i386/dvorak/custom.map"
	sudo -v; \
	sudo ln -s $(SRC)/.local/dvorak-programmer.map /usr/share/kbd/keymaps/i386/dvorak/custom.map
	@echo "==> Sudo access reqired to sed s/KEYMAP=.*/KEYMAP=custom/ /etc/vconsole.conf"
	sudo -v; \
	sudo sed s/KEYMAP=.*/KEYMAP=custom/ /etc/vconsole.conf | sudo tee /etc/vconsole.conf

# ---- session profiles ------------------------------------------------------


# a profile installs the configs that session needs (MODE=ln|cp, same as
# link-configs) and, for X11, points $(DST)/.xinitrc at its WM -- so
# `ls -l ~/.xinitrc` tells you which one is active.
#   x11     openbox (stacking)   wayland         labwc (stacking)
#   x11-tiling  i3               wayland-tiling  sway
# $(1) = space separated .config entry names
define link_config
	@for n in $(1); do \
		bash "$(INSTALL_SH)" "$(SRC)/.config/$$n" "$(DST)/.config/$$n" "$(MODE)"; \
	done
endef

profile-wayland:
	$(call link_config,labwc waybar)
	@rm -f "$(DST)/.xinitrc"
	@echo "==> [OK] wayland profile: labwc. run 'exec labwc' from the tty"
	@echo "         needs: labwc waybar swaybg fuzzel cliphist"

profile-wayland-tiling:
	$(call link_config,sway waybar)
	@rm -f "$(DST)/.xinitrc"
	@echo "==> [OK] wayland-tiling profile: sway. run 'exec sway' from the tty"
	@echo "         needs: sway swaybg swayidle i3status cliphist"

profile-x11:
	$(call link_config,openbox tint2)
	@ln -vsfn "$(SRC)/X11/.Xresources" "$(DST)/.Xresources"
	@ln -vsfn "$(SRC)/X11/xinitrc-openbox" "$(DST)/.xinitrc"
	@echo "==> [OK] x11 profile: openbox. run 'startx'. needs: openbox tint2 feh picom rofi"

profile-x11-tiling:
	$(call link_config,i3)
	@ln -vsfn "$(SRC)/X11/.Xresources" "$(DST)/.Xresources"
	@ln -vsfn "$(SRC)/X11/xinitrc-i3" "$(DST)/.xinitrc"
	@echo "==> [OK] x11-tiling profile: i3. run 'startx'. needs: i3-wm i3status feh picom rofi"

xorg-conf:
	@echo "==> Sudo access required to install X11/xorg.conf to /etc/X11/xorg.conf"
	sudo -v; \
	sudo install -Dm644 "$(SRC)/X11/xorg.conf" /etc/X11/xorg.conf

vim-dirs:
	@mkdir -p "$(DST)/.vim/undo" "$(DST)/.vim/backup" "$(DST)/.vim/swap"
	@touch $(HOME)/.profile.vim

tmux-plugins:
	@test -d "$(TPM_DIR)" || git clone https://github.com/tmux-plugins/tpm "$(TPM_DIR)"

vim-plug:
	@curl -fsSL -o "$(VIM_PLUG)" --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

link-root:
	@bash "$(INSTALL_SH)" "$(SRC)" "$(DST)"

link-configs:
	@shopt -s nullglob; \
		for p in "$(SRC)/.config"/*; do \
		n="$$(basename "$$p")"; \
		[[ "$$n" =~ ^[A-Za-z] ]] || continue; \
		bash "$(INSTALL_SH)" "$(SRC)/.config/$$n" "$(DST)/.config/$$n" "$(MODE)"; \
		done

link-local:
	@shopt -s nullglob; \
		for p in "$(SRC)/.local"/*; do \
		n="$$(basename "$$p")"; \
		[[ "$$n" =~ ^[A-Za-z] ]] || continue; \
		bash "$(INSTALL_SH)" "$(SRC)/.local/$$n" "$(DST)/.local/$$n" "$(MODE)"; \
		done

link-emacs:
	@bash "$(INSTALL_SH)" "$(SRC)/.emacs.d" "$(DST)/.emacs.d" "$(MODE)"

#TODO: add root required installation for X11 .conf files


build-vim: | build-vim-clean
	@set -euo pipefail; \
	os="$$(. /etc/os-release 2>/dev/null; echo "$${ID:-}")"; \
	arch="$$(uname -m)"; \
	if [[ "$$os" != "arch" ]]; then \
		echo "ERROR: build-vim requires Arch Linux (ID=arch), got '$$os'" >&2; \
		exit 1; \
	fi; \
	if [[ "$$arch" != "x86_64" ]]; then \
		echo "ERROR: build-vim requires host arch x86_64, got $$arch" >&2; \
		exit 1; \
	fi; \
	cd ./containers; \
	bash ./install.sh arch-amd64; \
	echo "==> Sudo access required to install vim to /usr/local/"; \
	sudo -v; \
	echo "==> Copying vim binary file to /usr/bin/vim..."; \
	if sudo cp -v ./arch-amd64/build/vim /usr/bin/vim; then \
		echo "==> [OK] vim binary installed to /usr/bin/vim"; \
	else \
		echo "ERROR: Failed to copy vim runtime files" >&2; exit 1; \
	fi; \
	sudo mkdir -p /usr/local/share/vim/; \
	if sudo cp -vr ./arch-amd64/build/vimdir/* /usr/local/share/vim/; then \
		echo "==> [OK] vim runtime files installed to /usr/local/share/vim/vim91"; \
	else \
		echo "ERROR: Failed to copy vim runtime files" >&2; exit 1; \
	fi; \
	echo "==> Build and install complete."

# If vim runtime is already compiled and must only be copied
build-vim-copy: 
	[ -f $(SRC)/containers/arch-amd64/build/vim && -d $(SRC)/containers/arch-amd64/build/vimdir ] && \
	sudo -v; \
	echo "==> Copying vim binary file to /usr/bin/vim..."; \
	if sudo cp -v $(SRC)/containers/arch-amd64/build/vim /usr/bin/vim; then \
		echo "==> [OK] vim binary installed to /usr/bin/vim"; \
	else \
		echo "ERROR: Failed to copy vim runtime files" >&2; exit 1; \
	fi; \
	sudo mkdir -p /usr/local/share/vim/; \
	if sudo cp -vr $(SRC)/containers/arch-amd64/build/vimdir/* /usr/local/share/vim/; then \
		echo "==> [OK] vim runtime files installed to /usr/local/share/vim/vim91"; \
	else \
		echo "ERROR: Failed to copy vim runtime files" >&2; exit 1; \
	fi; \
	echo "==> Build and install complete."

build-vim-clean: 
	@set -euo pipefail; \
	cd ./containers; \
	[ -d arch-amd64/build ] && rm -rf arch-amd64/build || true; \
	docker rm -f vim_build >/dev/null 2>&1 || true	
