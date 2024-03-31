source ~/.profile
source ~/.bashrc

# Homebrew path
export PATH=$PATH:/opt/homebrew/bin

export PATH=/Users/artem/bin:$PATH

[[ -s ~/.bashrc ]] && source ~/.bashrc

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/artem/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/artem/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/artem/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/artem/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Vim motions
set -o vi

# Aliases

alias tmKISS='tmux kill-server'
alias cpcr='cpp-c-r' 
alias brc='source ~/.bashrc'
alias g='git'
alias dr='docker'

. "$HOME/.cargo/env"

