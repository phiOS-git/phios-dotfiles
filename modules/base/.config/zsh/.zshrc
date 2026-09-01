# ~/.config/zsh/.zshrc

autoload -Uz compinit && compinit
autoload -Uz colors && colors

HISTFILE="$ZDOTDIR/.zhistory"
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '

eval "$(zoxide init zsh)"

# history substring search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

function y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"

    command yazi "$@" --cwd-file="$tmp"

    IFS= read -r -d '' cwd < "$tmp"
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ]; then
        builtin cd -- "$cwd"
    fi

    command rm -f -- "$tmp"
}

# nnn - bookmarks
export NNN_BMS="d:$HOME;D:$HOME/.config"
