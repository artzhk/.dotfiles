source ~/.bash_profile
source ~/.bashrc

# PATH
##If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/opt/homebrew/bin:/Users/artem/.config/emacs/bin:/usr/local:/usr/local/bin:/Users/artem/.local/scripts:/Users/artem/.local/bin:$PATH
export CMAKE_PREFIX_PATH="/opt/homebrew/Cellar/cppunit/lib/cmake/CppUnit:$CMAKE_PREFIX_PATH"

## Brew path
export PATH=/opt/homebrew/bin:$PATH
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export PATH="/Applications/CMake.app/Contents/bin":"$PATH"

## Conda Path
export PATH=$HOME/artem/miniforge3/bin:$PATH

## Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="dst-custom"
zstyle ':omz:update' mode reminder  # just remind me to update when it's time
plugins=(git zsh-autosuggestions)

# Mappings
bindkey "^E" autosuggest-accept

source $ZSH/oh-my-zsh.sh
source ~/.dotfiles/.aliases

set -o vi
bindkey -v

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias mysql="/usr/local/mysql/bin/mysql"
alias mysqladmin="/usr/local/mysql/bin/mysqladmin"
alias mysqlstart="sudo /usr/local/mysql/support-files/mysql.server start"
alias mysqlstop="sudo /usr/local/mysql/support-files/mysql.server stop"
alias expl="gh copilot explain"

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

eval "$(zoxide init zsh)"
export PATH="/opt/homebrew/opt/mysql/bin:$PATH"
