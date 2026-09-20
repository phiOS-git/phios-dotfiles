export ZDOTDIR="$HOME/.config/zsh"

# ~/.local/bin carries phiOS launchers installed as home symlinks
# (phi-agent-contain and anything a profile drops there). The systemd user
# units call it by absolute path; interactive use and the `phi-code` helper
# need it on PATH. `typeset -U` keeps PATH duplicate-free if re-sourced.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

# PHI_DOTFILES — where `phi` and phi-shell's capability probe look for this
# repository. The built-in default is ~/phios-dotfiles (standard install path).
# A checkout kept elsewhere (dev tree) needs this set or `phi theme` and
# `phi doctor` fail silently. phios-install writes the real path to
# ~/.config/phios/dotfiles-root on every run; read it here so the TTY login
# shell and everything it starts (Hyprland, quickshell) inherit the right
# value. Falls back to the canonical location when the pointer doesn't exist.
if [[ -z ${PHI_DOTFILES:-} ]]; then
    _phi_root_file="${XDG_CONFIG_HOME:-$HOME/.config}/phios/dotfiles-root"
    [[ -r $_phi_root_file ]] && PHI_DOTFILES="$(<"$_phi_root_file")"
    unset _phi_root_file
fi
export PHI_DOTFILES="${PHI_DOTFILES:-$HOME/phios-dotfiles}"
