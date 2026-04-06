#!/bin/bash

source ~/.dotfiles/bash/aliases.sh

export PATH=~/.cargo/bin:$PATH
export PATH=~/go/bin:$PATH
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

set -o emacs

# bash history
unset HISTFILESIZE
export HISTFILE=~/.bash_history
HISTSIZE=10000
PROMPT_COMMAND="history -a"
export HISTSIZE PROMPT_COMMAND
export HISTIGNORE="ls:pwd:exit:clear:history:mkdir"

history -r ~/.bash_history
shopt -s histappend

# FZF 
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!.{git,venv,env,cache}/*" -g "!.*{DS_Store,swp,pyc,db}"'
export FZF_DEFAULT_OPTS='--preview "cat {}" --preview-window=right:50%:hidden --bind=ctrl-/:toggle-preview,alt-a:select-all,alt-d:deselect-all --tiebreak=end,pathname,chunk'

# command line appearance
## functions 
git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
PS1="\[\e[0m\]\u \[\e[1;34m\]\w \[\e[0;31m\]\$(git_branch)\n\[\e[1;34m\]$\[\e[0m\] "

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion


[[ -f $HOME/.profile ]] && source $HOME/.profile
