#
# ~/.bashrc
#

export PATH=/home/art/.local/bin:$PATH
export PATH=/home/art/.local/scripts:$PATH
export PATH=/home/art/.dotnet/tools:$PATH

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
alias vim="nvim"
alias lg="lazygit"
alias math="genius"
alias s1="i3-resurrect save -w 1"
alias s2="i3-resurrect save -w 2"
alias w1="i3-resurrect restore -w 1"
alias w2="i3-resurrect restore -w 2"
alias cd="z"
alias vv="select_vim"

alias v="NVIM_APPNAME=nvim nvim"
alias v_dev="NVIM_APPNAME=nvim_dev nvim"

PS1='[\u@\h \W]\$ '

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

