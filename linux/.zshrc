source ~/.bash_profile

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.local/scripts:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Rofi
export PATH=$HOME/.config/rofi/scripts:$PATH#

ZSH_THEME="dst-custom"
export EDITOR='nvim'
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(git zsh-autosuggestions)
# Autosuggestion mappings
bindkey '^E' autosuggest-accept

source $ZSH/oh-my-zsh.sh

# Compilation flags
export ARCHFLAGS="-arch x86_64"

set -o vi

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/art/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
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

export BAT_THEME=gruvbox-light

eval "$(zoxide init zsh)"
