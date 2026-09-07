# phiOS — shared helpers for the bootstrap scripts.
#
# Sourced by bin/phios-*; never executed on its own.
#
# Dependency budget (master plan R9): bash, coreutils, git, gettext. Nothing
# here may reach for anything else, because these scripts have to run on a
# freshly installed machine, before `phi` exists.
#
# All output is plain text on purpose: an ANSI escape written here would be a
# colour living outside design/, which I-05 forbids.

phios_out()  { printf '%s\n' "$*"; }
phios_warn() { printf 'phios: warning: %s\n' "$*" >&2; }
# Exit 2, so a caller can tell a failure apart from the drift that --check
# and --system-diff report with exit 1.
phios_die()  { printf 'phios: error: %s\n' "$*" >&2; exit 2; }

phios_require_cmd() {
	local cmd=$1 reason=${2:-}
	if ! command -v -- "$cmd" >/dev/null 2>&1; then
		phios_die "required command not found: $cmd${reason:+ — $reason}"
	fi
}

# Records go through these two so the field separator is defined in one place.
phios_join_fields() {
	local out=$1
	shift
	local field
	for field in "$@"; do out+=$'\t'$field; done
	printf '%s\n' "$out"
}

# Lines of a plain-text list file, with comments and blank lines removed and
# surrounding whitespace trimmed. A missing file is not an error: an absent
# packages.txt means "this profile installs nothing".
phios_read_list() {
	local file=$1 line
	[[ -f $file ]] || return 0
	while IFS= read -r line || [[ -n $line ]]; do
		line=${line%%#*}
		line=${line#"${line%%[![:space:]]*}"}
		line=${line%"${line##*[![:space:]]}"}
		if [[ -n $line ]]; then printf '%s\n' "$line"; fi
	done < "$file"
	return 0
}

phios_sha256() {
	local out
	out=$(sha256sum -- "$1")
	printf '%s\n' "${out%% *}"
}

# Symlinks are written relative so the tree survives being moved or bind-mounted.
phios_relpath() {
	realpath -m --relative-to="$1" -- "$2"
}

phios_state_dir() {
	printf '%s\n' "${XDG_STATE_HOME:-$HOME/.local/state}/phios"
}

# Runtime state belongs to `phi`, not to the repository (master plan §5.6).
# The installer only ever reads it.
phios_runtime_dir() {
	printf '%s\n' "${XDG_STATE_HOME:-$HOME/.local/state}/phi"
}
