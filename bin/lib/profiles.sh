# phiOS — host identity and profile resolution.
#
# hosts/<host>.txt lists the profiles applied to that host, in order. The order
# is significant: a profile providing a concrete provider must precede one that
# requires it (master plan §5.3). Resolution therefore preserves file order and
# never sorts.

# Explicit --host wins, then $PHIOS_HOST, then the machine's own name. The
# domain part is dropped: hosts/ is keyed on the short name.
phios_resolve_host() {
	local host=${PHIOS_HOST:-}
	if [[ -z $host && -r /etc/hostname ]]; then
		read -r host < /etc/hostname || host=''
	fi
	[[ -n $host ]] || host=$(uname -n)
	host=${host%%.*}
	[[ -n $host ]] || phios_die 'cannot determine the host name; pass --host NAME'
	printf '%s\n' "$host"
}

phios_host_file() {
	printf '%s\n' "$PHIOS_ROOT/hosts/$1.txt"
}

# Directories under profiles/ that look like a profile. Used only to tell the
# transitional empty state apart from a genuine typo in a host file.
phios_profiles_available() {
	local dir
	[[ -d $PHIOS_ROOT/profiles ]] || return 0
	for dir in "$PHIOS_ROOT"/profiles/*/; do
		[[ -d $dir ]] || continue
		dir=${dir%/}
		printf '%s\n' "${dir##*/}"
	done
	return 0
}

# Fills PHIOS_PROFILES with the profiles declared for $PHIOS_HOSTNAME.
#
# S-01 builds the machinery; S-03 moves modules/ into profiles/. While
# profiles/ is still empty there is nothing to plan, and that is a clean run
# rather than an error — the host files still name the old modules. As soon as
# a single profile directory exists, a declared name without a directory is a
# hard error again, so a typo can never be silently skipped.
phios_resolve_profiles() {
	local host_file declared available name
	host_file=$(phios_host_file "$PHIOS_HOSTNAME")
	[[ -f $host_file ]] || phios_die "no profile list for this host: hosts/$PHIOS_HOSTNAME.txt"

	mapfile -t declared < <(phios_read_list "$host_file")
	mapfile -t available < <(phios_profiles_available)

	PHIOS_PROFILES=()
	PHIOS_PROFILES_PENDING=()

	if (( ${#available[@]} == 0 )); then
		PHIOS_PROFILES_PENDING=("${declared[@]+"${declared[@]}"}")
		return 0
	fi

	for name in "${declared[@]+"${declared[@]}"}"; do
		[[ -d $PHIOS_ROOT/profiles/$name ]] ||
			phios_die "hosts/$PHIOS_HOSTNAME.txt declares an unknown profile: $name"
		PHIOS_PROFILES+=("$name")
	done
	return 0
}
