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

# git diff interactive
alias gdi="git status -s | cut -d \" \" -f 3 | fzf --preview=\"git diff --color {}\" "

# git diff head to selected commit for file [git diff current -> commit]
alias gdcc="git diff \$(git log --pretty=format:\"%H %cI %d%x20%s\" | fzf | cut -d \" \" -f 1) HEAD"
alias gddcc="git difftool \$(git log --pretty=format:\"%H %cI %d%x20%s\" | fzf | cut -d \" \" -f 1) HEAD "
alias gdccf=commits_per_file
alias gddccf=difftool_commits_per_file
commits_per_file() {
  local f=$1 c
  c=$(git log --color=always --pretty=format:'%h %cI%d %s %an' --follow -- "$f" |
      fzf --ansi --no-sort \
          --preview="git diff --color=always {1} HEAD -- $(printf '%q' "$f")" |
      cut -d' ' -f1)
  [ -n "$c" ] && git diff "$c" HEAD -- "$f"
}
difftool_commits_per_file() {
	git difftool $(git log --pretty=format:"%h %cI %d%x20%s %an" --follow $1 | fzf --preview=\"git diff --color {}\" | cut -d " " -f 1) HEAD $1
}

# git worktree
alias gw="git worktree"
# TODO: Can be converted to the functions that accepts path to worktrees
alias gwar="ggr | xargs -n3 sh -c 'git worktree add -f ~/repos/wt/\$1 \$1' sh"
alias gwarb="ggr | xargs -n3 sh -c 'git worktree add -f ~/repos/wt/\$1 -b \$1' sh"
# remove worktrees
alias gwrr="git worktree list | awk '{print $1}' | xargs -p -I{} git worktree remove -f {}"

# git graph
alias glga="git log --graph --color=always --full-history --all --pretty=format:\"%C(auto)%h | %cn | %ah | %d%x20%s\""
alias glg="git log --graph --color=always --full-history --pretty=format:\"%C(auto)%h | %cn | %ah | %d%x20%s\""

# Remove inactive images
alias ddrmii="docker rmi \$(docker images -q)"
alias dda="docker ps -a"
# Docker remove all inactive containers
alias ddrmci="docker rm \$(docker ps -a -q)"

gif() {
    if [[ -f "$1" ]]; then
        ffmpeg -i "$1" \
            -vf "split[s0][s1];[s0]palettegen=max_colors=256:stats_mode=diff[p];[s1][p]paletteuse=dither=floyd_steinberg" \
            "${1%.*}.gif"
    else
        ffmpeg -ss "$1" -to "$2" -i "$3" \
            -vf "split[s0][s1];[s0]palettegen=max_colors=256:stats_mode=diff[p];[s1][p]paletteuse=dither=floyd_steinberg" \
            "${3%.*}.gif"
    fi
}
secure-ramfs-on() {
    local src=/mnt ram=/run/user/$UID/secure-ramfs link=$HOME/.2fa
    [ -e "$link" ] && [ ! -L "$link" ] && { echo "$link exists and is not a symlink, aborting"; return 1; }
    sudo mkdir -p "$ram"
    sudo mount -t ramfs -o mode=0700 ramfs "$ram"
    sudo cp -a "$src/.gnupg" "$ram/gnupg"
    sudo cp -a "$src/.2fa" "$ram/2fa"
    sudo rm -f "$ram"/gnupg/S.*                       # drop stale agent sockets
    sudo chown -R "$(id -u):$(id -g)" "$ram"    # ownership changes only on the RAM copy
    export GNUPGHOME="$ram/gnupg"
    ln -sfn "$ram/2fa" "$link"
    gpg --homedir $GNUPGHOME --list-keys >/dev/null && echo "GnuPG in RAM: $ram/gnupg\n"
    ls "$ram/2fa" && echo "2FA ready."
}

secure-ramfs-off() {
    local ram=/run/user/$UID/secure-ramfs
    gpgconf --homedir "$ram/gnupg" --kill all         # stop the agent and clear its cache
    [ -L "$HOME/.2fa" ] && rm "$HOME/.2fa"              # removes only the link, never a real directory   
    sudo umount "$ram" && sudo rmdir "$ram"     # free the RAM pages
    unset GNUPGHOME
}

