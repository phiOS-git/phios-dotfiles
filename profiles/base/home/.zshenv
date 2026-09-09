export ZDOTDIR="$HOME/.config/zsh"

# ~/.local/bin carries phiOS launchers installed as home symlinks —
# phi-agent-contain (S-70), and anything a later profile drops there.
# The systemd user units call it by absolute path; interactive use and the
# `phi-code` helper (profiles/desktop .../zsh/agent.zsh) need it on PATH.
# `typeset -U` keeps PATH duplicate-free if this file is re-sourced.
typeset -U path PATH
path=("$HOME/.local/bin" $path)
