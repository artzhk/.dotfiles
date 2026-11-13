SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

SRC ?= $(HOME)/.dotfiles
DST ?= $(HOME)
DRY ?=

SYS_DIR  ?= /usr/local/share/dotfiles-system
SYS_PKGS ?= x11-common console

STOW    = stow --no-folding -d "$(SRC)" $(if $(DRY),-n -v)
TPM_DIR := $(DST)/.tmux/plugins/tpm
X11_PKGS := x11 x11-openbox x11-i3

.PHONY: help install install-default link unlink check clean-legacy tmux-plugins \
        profile-wayland profile-wayland-tiling profile-x11 profile-x11-tiling \
        xorg-conf tty-keymap

help:
	@echo "usage: make <target> [SRC=...] [DST=...] [DRY=1]"
	@echo ""
	@echo "  install          tmux-plugins + link"
	@echo "  install-default  install with SRC=~/.dotfiles DST=~"
	@echo "  link             stow home, .config, .local, .emacs.d"
	@echo "  unlink           unstow all of the above"
	@echo "  check            dry run of link (shows conflicts)"
	@echo "  clean-legacy     remove old absolute links into SRC (try DRY=1 first)"
	@echo "  tmux-plugins     clone tpm if missing"
	@echo "  profile-wayland | profile-wayland-tiling | profile-x11 | profile-x11-tiling"
	@echo "  xorg-conf        sudo: X11/xorg.conf -> /etc/X11/xorg.conf"
	@echo "  tty-keymap       sudo: dvorak-programmer console keymap"

install: tmux-plugins link
	@echo "==> [OK] SRC=$(SRC) DST=$(DST)$(if $(DRY), (dry run))"

install-default:
	@$(MAKE) --no-print-directory install SRC="$(HOME)/.dotfiles" DST="$(HOME)"

link:
	@mkdir -p "$(DST)/.config" "$(DST)/.local" "$(DST)/.emacs.d"
	$(STOW) -t "$(DST)"          -R home 
	$(STOW) -t "$(DST)/.config"  -R .config --adopt
	$(STOW) -t "$(DST)/.local"   -R .local
	$(STOW) -t "$(DST)/.emacs.d" -R .emacs.d

unlink:
	$(STOW) -t "$(DST)"          -D home $(X11_PKGS)
	$(STOW) -t "$(DST)/.config"  -D .config
	$(STOW) -t "$(DST)/.local"   -D .local
	$(STOW) -t "$(DST)/.emacs.d" -D .emacs.d

check:
	@$(MAKE) --no-print-directory link DRY=1

clean-legacy:
	@find "$(DST)" -maxdepth 4 -xdev -type l \
		\( -lname '$(SRC)' -o -lname '$(SRC)/*' \) \
		$(if $(DRY),-print,-print -delete)

tmux-plugins:
	@test -d "$(TPM_DIR)" || git clone -q https://github.com/tmux-plugins/tpm "$(TPM_DIR)"

# ---- session profiles: `ls -l ~/.xinitrc` shows the active X11 one ----------

profile-wayland:
	$(STOW) -t "$(DST)" -D $(X11_PKGS)
	@echo "==> [OK] labwc. run 'exec labwc'. needs: labwc waybar swaybg fuzzel cliphist"

profile-wayland-tiling:
	$(STOW) -t "$(DST)" -D $(X11_PKGS)
	@echo "==> [OK] sway. run 'exec sway'. needs: sway swaybg swayidle i3status cliphist"

profile-x11:
	$(STOW) -t "$(DST)" -D x11-i3
	$(STOW) -t "$(DST)" -R x11 x11-openbox
	@echo "==> [OK] openbox. run 'startx'. needs: openbox tint2 feh picom rofi"

profile-x11-tiling:
	$(STOW) -t "$(DST)" -D x11-openbox
	$(STOW) -t "$(DST)" -R x11 x11-i3
	@echo "==> [OK] i3. run 'startx'. needs: i3-wm i3status feh picom rofi"

# ---- root-required: host only, never from the DaemonSet --------------------

xorg-conf:
	sudo install -Dm644 "$(SRC)/X11/xorg.conf" /etc/X11/xorg.conf

# https://unix.stackexchange.com/questions/709302/how-to-remap-ctrl-to-caps-lock-in-a-tty
tty-keymap:
	@if [[ "$$(uname -v)" == *Debian* || "$$(uname -v)" == *Ubuntu* ]]; then \
		echo "Debian/Ubuntu: see keyboard(5)" >&2; exit 1; fi
	sudo ln -sfn "$(SRC)/.local/us-control.map" /usr/share/kbd/keymaps/i386/dvorak/custom.map
	sudo sed -i 's/^KEYMAP=.*/KEYMAP=custom/' /etc/vconsole.conf

system:
	@if [[ -d "$(SYS_DIR)" ]]; then sudo stow -d "$(SYS_DIR)" -t / -D $(SYS_PKGS); fi
	sudo install -d -o root -g root -m 0755 "$(SYS_DIR)"
	sudo rsync -a --delete --chown=root:root --chmod=D755,F644 "$(SRC)/system/" "$(SYS_DIR)/"
	sudo stow --no-folding -d "$(SYS_DIR)" -t / -R $(SYS_PKGS)

system-check:
	sudo stow --no-folding -n -v -d "$(SYS_DIR)" -t / -R $(SYS_PKGS)

system-unlink:
	sudo stow -d "$(SYS_DIR)" -t / -D $(SYS_PKGS)
