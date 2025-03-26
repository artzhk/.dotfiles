ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg_bold[yellow]%}ඞ"

PROMPT='%n %{$fg_bold[blue]%}%/%{$fg_bold[red]%}$(git_prompt_info)
%{$fg[blue]%}$%{$reset_color%} '

