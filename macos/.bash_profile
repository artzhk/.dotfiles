source ~/.profile
source ~/.bashrc

# Homebrew path
export PATH=$PATH:/opt/homebrew/bin
export PATH="/usr/local/:$PATH"
export PATH="/usr/local/bin:$PATH"

export PATH=/Users/artem/bin:$PATH

export CMAKE_PREFIX_PATH="/opt/homebrew/Cellar/cppunit/lib/cmake/CppUnit:$CMAKE_PREFIX_PATH"

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

# User configuration
git config --global core.editor nvim

# Vim motions
set -o vi

# Aliases

alias tmKISS='tmux kill-server'
alias tmns='tmux-session'
alias cpcr='cpp-c-r' 
alias brc='source ~/.bash_profile'
alias g='sudo git'
alias t='tree'
alias lg="sudo lazygit"
alias cd="z"
alias vv="select_vim"
alias v="NVIM_APPNAME=nvim nvim"
alias v_dev="NVIM_APPNAME=nvim_dev nvim"

. "$HOME/.cargo/env"

