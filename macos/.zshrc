source ~/.bash_profile

#If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:/Users/artem/.local/scripts:$PATH

# Conda Path
export PATH=$HOME/artem/miniforge3/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Brew path
export PATH=/opt/homebrew/bin:$PATH

export PATH=/opt/local/bin:/opt/local/sbin:$PATH

export PATH="/Applications/CMake.app/Contents/bin":"$PATH"

ZSH_THEME="dst-custom"

 zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to disable colors in ls.
 DISABLE_LS_COLORS="false"

# Uncomment the following line to disable auto-setting terminal title.
 DISABLE_AUTO_TITLE="false"

plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias mysql="/usr/local/mysql/bin/mysql"
alias mysqladmin="/usr/local/mysql/bin/mysqladmin"
alias mysqlstart="sudo /usr/local/mysql/support-files/mysql.server start"
alias mysqlstop="sudo /usr/local/mysql/support-files/mysql.server stop"

set -o vi

# compdef _gnu_generic timg

#source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/artem/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/artem/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/artem/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/artem/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/:$PATH"

export PATH="$HOME/bin:$PATH"

eval "$(zoxide init zsh)"
