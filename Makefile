SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

SRC ?= $(HOME)/.dotfiles
DST ?= $(HOME)
MODE ?= ln

TPM_DIR := $(DST)/.tmux/plugins/tpm
VIM_PLUG := $(DST)/.vim/autoload/plug.vim
INSTALL_SH := $(SRC)/.install/install.sh

.PHONY: help install install-default vim-dirs tmux-plugins vim-plug link-root link-configs build-vim

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
	@echo "  build-vim       Arch Linux x86_64 only: build vim in ./containers/arch-amd64 then"
	@echo "                  copy vim -> /usr/local/vim and runtime -> /usr/local/share/vim/"
	@echo ""
	@echo "examples:"
	@echo "  make install"
	@echo "  make install DST=/tmp/home"
	@echo "  make install SRC=$$PWD DST=$$HOME MODE=cp"
	@echo "  make build-vim"

install: vim-dirs tmux-plugins vim-plug link-root link-configs
	@echo "dotfiles installed: SRC=$(SRC) DST=$(DST) MODE=$(MODE)"

install-default:
	@$(MAKE) install SRC="$(HOME)/.dotfiles" DST="$(HOME)" MODE="ln"

vim-dirs:
	@mkdir -p "$(DST)/.vim/undo" "$(DST)/.vim/backup" "$(DST)/.vim/swap"

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

build-vim:
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
	cp -v  ./arch-amd64/build/vim /usr/local/vim; \
	mkdir -p /usr/local/share/vim/; \
	cp -vr ./arch-amd64/build/vimdir/vim91 /usr/local/share/vim/
