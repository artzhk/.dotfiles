#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -larth'
alias grep='grep --color=auto'

alias grE=grep_exclude
grep_exclude() {
	grep --color=auto -v -E \"$*\"
}

mkcd() {
	mkdir -p $1 && cd $1
}

# pretier eslint on staged/unstaged fies
alias esla="eslint --fix \$(git status --untracked-files -s | grep -e '^.[??|M| M|UU].*ts\w*$' | cut -c 4-)"
alias preta="prettier -c \$(git status --untracked-files -s | grep -e '^.[??|M| M|UU].*ts\w*$' | cut -c 4-) -w"

# grep directory
alias tmKISS='tmux kill-server'
alias brc='source ~/.bash_profile'
alias lg="lazygit"

# git basics
alias g="git"
alias guc="git push -u origin \$(git branch --show-current)"
alias gp="git pull"
alias gP="git push"
alias gs="git status"
alias ga="git add"
alias gap="git add --patch"

# git commit
alias gc="git commit"
alias gC='bash -c "read -p \"Commit Message: \" rep; git commit -m \"\$rep\" "'
alias gca="git commit --allow-empty --amend --only"
# git get hash
alias ggh="git log --pretty=format:\"%H %d%x20%s %cI\" | fzf | cut -d \" \" -f 1"

# git checkout
# git get remote
alias ggr="git branch --remote | fzf | sed  \"s/origin\///g\" | tr -d \" \""
# git checkout branch remote
alias gcbr='bash -c "git checkout \$(git branch -r | sed \"s/origin\///\" | fzf)"'
alias gcb='bash -c "git checkout \$(git branch | sed \"s/origin\///\" | fzf)"'

# git diff
alias gd="git diff"
alias gdd="git difftool"
alias gds="git diff --staged"

# git diff interactive
alias gdi="git status -s | cut -d \" \" -f 3 | fzf --preview=\"git diff --color {}\" "

# git diff head to selected commit for file [git diff current -> commit]
alias gdcc="git diff \$(git log --pretty=format:\"%H %cI %d%x20%s\" | fzf | cut -d \" \" -f 1) HEAD"
alias gddcc="git difftool \$(git log --pretty=format:\"%H %cI %d%x20%s\" | fzf | cut -d \" \" -f 1) HEAD "
alias gdccf=commits_per_file
alias gddccf=difftool_commits_per_file
commits_per_file() {
	git diff $(git log --pretty=format:"%H %cI %d%x20%s" --follow $1 | fzf | cut -d " " -f 1) HEAD $1
}
difftool_commits_per_file() {
	git difftool $(git log --pretty=format:"%H %cI %d%x20%s" --follow $1 | fzf | cut -d " " -f 1) HEAD $1
}

# git diff file select
alias gdf="git diff \$(git status -s | grep -v '^ D' | grep -v '.swp$' | cut -c 4- | fzf)"
alias gddf="git difftool \$(git status -s | grep -v '^ D' | grep -v '.swp$' | cut -c 4- | fzf)"
# TODO: git get all commits for file
# fzf list to restor to select from
alias gr="git restore"
alias grs="git restore --staged"

# git worktree
alias gw="git worktree"
# TODO: Can be converted to the functions that accepts path to worktrees
alias gwar="ggr | xargs -n3 sh -c 'git worktree add -f ~/repos/wt/\$1 \$1' sh"
alias gwarb="ggr | xargs -n3 sh -c 'git worktree add -f ~/repos/wt/\$1 -b \$1' sh"

# git graph
alias glga="git log --graph --color=always --full-history --all --pretty=format:\"%C(auto)%h | %cn | %ah | %d%x20%s\""
alias glg="git log --graph --color=always --full-history --pretty=format:\"%C(auto)%h | %cn | %ah | %d%x20%s\""

# Docker
alias dd="docker"
# Remove inactive images
alias ddrmii="docker rmi \$(docker images -q)"
alias dda="docker ps -a"
# Docker remove all inactive containers
alias ddrmci="docker rm \$(docker ps -a -q)"

# NM cli 
# Select and connect
alias nc="nmcli d wifi connect \$(nmcli d wifi list | awk 'BEGIN {FIELDWIDTHS = \"10 16 14\"} {print  \$2\"*\"\$3}' | fzf | cut -d \"*\" -f 2 | tr -d \" \")"
