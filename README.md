# dotfiles
_THIS FILE IS GENERETED BY LLM, THUS IT MAY CONTAIN INCONSISTENCES_

Personal dotfiles managed via `make`. Supports symlinking or copying config files into a home directory.

## Prerequisites

- `bash`, `git`, `curl`
- Docker — only required for `build-vim`

## Variables

| Variable | Default            | Description                                      |
|----------|--------------------|--------------------------------------------------|
| `SRC`    | `~/.dotfiles`      | Dotfiles source directory                        |
| `DST`    | `~`                | Destination home directory to install into       |
| `MODE`   | `ln`               | Install mode for `.config` entries: `ln` (symlink) or `cp` (copy) |

## Targets

| Target            | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `help`            | Show usage, variables, targets, and examples                                |
| `install`         | Full install: vim dirs, tmux tpm, vim-plug, link root and `.config/*`       |
| `install-default` | Same as `install` with `SRC=~/.dotfiles DST=~ MODE=ln`                     |
| `vim-dirs`        | Create `$DST/.vim/{undo,backup,swap}`                                       |
| `tmux-plugins`    | Install tmux TPM into `$DST/.tmux/plugins/tpm` if missing                  |
| `vim-plug`        | Install vim-plug into `$DST/.vim/autoload/plug.vim`                        |
| `link-root`       | Run `.install/install.sh` for `SRC → DST` (root-level dotfiles)            |
| `link-configs`    | Link each `$SRC/.config/<name>` → `$DST/.config/<name>` using `MODE`       |
| `link-local`      | Link each `$SRC/.local/<name>` → `$DST/.local/<name>` using `MODE`         |
| `link-emacs`      | Link `$SRC/.emacs.d` → `$DST/.emacs.d` using `MODE`                        |
| `build-vim`       | Arch Linux x86_64 only: build vim in `./containers/arch-amd64`, then install binary to `/usr/bin/vim` and runtime to `/usr/local/share/vim/` |

## Usage

```sh
# Standard install (symlinks, default paths)
make install

# Install into a custom destination
make install DST=/tmp/home

# Install using copies instead of symlinks
make install SRC=$PWD DST=$HOME MODE=cp

# Cross compiling and install vim (Arch Linux x86_64 only)
# to add another distro or os, create a folder with Dockerfile and dependencies needed
make build-vim
```

Run `make help` for the full reference.
