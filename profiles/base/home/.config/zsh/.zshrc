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
# fastfetch's info column can be taller than a short terminal window, which
# scrolls its top rows out of view before the prompt ever draws. Pick by
# $LINES instead: full config.jsonc when the window is tall enough, the
# undecorated compact.jsonc when it is not, otherwise just clear. The two
# thresholds are each config's module-row count (one row per module, a
# "break" or a custom box line counts as one, "colors" as two) versus the
# logo's padding.top plus phi-ascii.txt's 19 lines, whichever is taller,
# plus one row for the prompt and two for hosts where "disk" or "gpu"
# prints more than one row (zotac's second disk) — update them if either
# file's modules change.
() {
    local fastfetch_full_min_lines=33
    local fastfetch_compact_min_lines=23
    clear
    if (( LINES >= fastfetch_full_min_lines )); then
        fastfetch
    elif (( LINES >= fastfetch_compact_min_lines )); then
        fastfetch --config ~/.config/fastfetch/compact.jsonc
    fi
}
