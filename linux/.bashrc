#
# ~/.bashrc
#

source ~/.local/state/colorscheme/.system_theme

export PATH=/usr/local/bin:$PATH
export PATH=/home/art/.local/bin:$PATH
export PATH=/home/art/.local/scripts:$PATH
export PATH=/home/art/dotnet/tools:$PATH

# Env config
export GTK_THEME="Raleigh"
export BAT_THEME="base16"
export EDITOR="vim"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias tmKISS='tmux kill-server'
alias tmns='tmux-session'
alias cpcr='cpp-c-r' 
alias brc='source ~/.bash_profile'
alias g='git'
alias t='tree'
alias lg="lazygit"
alias math="genius"
alias s1="i3-resurrect save -w 1"
alias s2="i3-resurrect save -w 2"
alias w1="i3-resurrect restore -w 1"
alias w2="i3-resurrect restore -w 2"
alias vv="select_vim"
alias livegrep="fzf --preview 'cat {}' --bind 'ctrl-j:down,ctrl-k:up'"
alias cd="z"
alias gp="git pull"
alias gP="git push"
alias gs="git status"
alias gaa="git add ."
alias ga="git add"
alias gc='bash -c "read -p \"Commit Message: \" rep; git commit -m \$rep "'
# fzf list to restor to select from
alias gr="git restore"
alias gbr='bash -c "git checkout \$(git branch -r | sed \"s/origin\///\" | fzf)"'

alias v="NVIM_APPNAME=nvim nvim"
alias vs="NVIM_APPNAME=nvim nvim -S Session.vim"
alias v_dev="NVIM_APPNAME=nvim_dev nvim"

set -o vi

# bash history
unset HISTFILESIZE
HISTSIZE=3000
PROMPT_COMMAND="history -a"
export HISTSIZE PROMPT_COMMAND

shopt -s histappend

# functions 
git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

PS1="\[\e[0;97m\]\u \[\e[1;34m\]\w \[\e[0;31m\]\$(git_branch)\n\[\e[1;34m\]$\[\e[0;30m\] "

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

export FZF_DEFAULT_OPTS='
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'

# export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
#   --color=fg:#545464,fg+:#624c83,bg:#ffffff,bg+:#dcd7ba
#   --color=hl:#6693bf,hl+:#d27e99,info:#6e915f,marker:#545464
#   --color=prompt:#545464,spinner:#624c83,pointer:#d27e99,header:#5a7785
#   --color=gutter:#dcd7ba,border:#262626,preview-border:#545464,preview-scrollbar:#545464
#   --color=preview-label:#545464,label:#545464,query:#545464
#   --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
#   --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'

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
. "$HOME/.cargo/env"
