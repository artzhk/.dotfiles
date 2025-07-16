#!/bin/bash

source ~/.dotfiles/bash/.aliases

export PATH=~/.cargo/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=~/.local/bin:$PATH
export PATH=~/.local/scripts:$PATH
export PATH=~/.local/watches:$PATH
export PATH=~/dotnet/tools:$PATH

# Env config
export GTK_THEME="Arc"
export BAT_THEME="ansi"
export EDITOR="vim"
export QT_STYLE_OVERRIDE=kvantum
export QT_QPA_PLATFORMTHEME=kvantum

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi

# bash history
unset HISTFILESIZE
HISTSIZE=3000
PROMPT_COMMAND="history -a"
export HISTSIZE PROMPT_COMMAND

shopt -s histappend

# FZF 
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!.{git,venv,.venv,env,cache}/*" -g "!.*{DS_Store,swp,pyc,db}"'
export FZF_DEFAULT_OPTS='--preview "bat --color=always {}" --preview-window=right:50%:hidden --bind=ctrl-/:toggle-preview'

# command line appearance
## functions 
git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
PS1="\[\e[0m\]\u \[\e[1;34m\]\w \[\e[0;31m\]\$(git_branch)\n\[\e[1;34m\]$\[\e[0m\] "

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/art/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/art/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/art/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/art/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

eval "$(zoxide init bash)"
source ~/.local/share/blesh/ble.sh

if [ -f ~/.profile ]; then
    source ~/.profile
fi
