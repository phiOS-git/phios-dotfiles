export ZDOTDIR="$HOME/.config/zsh"

# ~/.local/bin carries phiOS launchers installed as home symlinks —
# phi-agent-contain (S-70), and anything a later profile drops there.
# The systemd user units call it by absolute path; interactive use and the
# `phi-code` helper (profiles/desktop .../zsh/agent.zsh) need it on PATH.
# `typeset -U` keeps PATH duplicate-free if this file is re-sourced.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

# PHI_DOTFILES — where `phi` (tokens.Root, phi/internal/tokens/tokens.go)
# and phi-shell's capability probe look for this repository. Their built-in
# default is ~/phios-dotfiles, the path every install procedure clones to;
# a checkout kept anywhere else (a dev tree) needs this set or `phi theme`,
# `phi doctor` and the capability probe silently fail to find it (OOP-34).
# phios-install writes the real path to ~/.config/phios/dotfiles-root on
# every run — read it here, so the TTY login shell and everything it starts
# (Hyprland, and through it quickshell) inherit the right value. Falls back
# to the canonical location when the pointer file does not exist yet.
if [[ -z ${PHI_DOTFILES:-} ]]; then
    _phi_root_file="${XDG_CONFIG_HOME:-$HOME/.config}/phios/dotfiles-root"
    [[ -r $_phi_root_file ]] && PHI_DOTFILES="$(<"$_phi_root_file")"
    unset _phi_root_file
fi
export PHI_DOTFILES="${PHI_DOTFILES:-$HOME/phios-dotfiles}"
