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
eval "ssh-agent -s"

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
source "$ZDOTDIR/theme.zsh"

# phiOS AI agent shell helpers, desktop profile only. Defines `phi-code` for
# a contained A2 session.
[ -r "$ZDOTDIR/agent.zsh" ] && source "$ZDOTDIR/agent.zsh"


# GREETING
# fastfetch's output must fit the window whole, or it wraps and scrolls its
# top rows out of view. The full config.jsonc needs about 30 rows by 80
# columns, the undecorated compact.jsonc about 20 by 80 (more on hosts
# listing a second disk or GPU); each tier asks for a margin on both axes
# above that, and below the compact limits the shell just clears.
() {
    local full_min_lines=36 full_min_columns=100
    local compact_min_lines=28 compact_min_columns=90
    clear
    if (( LINES >= full_min_lines && COLUMNS >= full_min_columns )); then
        fastfetch
    elif (( LINES >= compact_min_lines && COLUMNS >= compact_min_columns )); then
        fastfetch --config ~/.config/fastfetch/compact.jsonc
    fi
}
