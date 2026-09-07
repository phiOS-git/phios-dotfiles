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

# Fills PHIOS_PROFILES with the profiles declared for $PHIOS_HOSTNAME.
#
# A declared name without a directory under profiles/ is a hard error, so a
# typo in a host file can never be silently skipped. S-01 and S-02 tolerated an
# empty profiles/ as the transitional state while modules/ was still the live
# tree; S-03 filled it, and that tolerance is gone with it.
phios_resolve_profiles() {
	local host_file declared name
	host_file=$(phios_host_file "$PHIOS_HOSTNAME")
	[[ -f $host_file ]] || phios_die "no profile list for this host: hosts/$PHIOS_HOSTNAME.txt"

	mapfile -t declared < <(phios_read_list "$host_file")

	PHIOS_PROFILES=()
	for name in "${declared[@]+"${declared[@]}"}"; do
		[[ -d $PHIOS_ROOT/profiles/$name ]] ||
			phios_die "hosts/$PHIOS_HOSTNAME.txt declares an unknown profile: $name"
		PHIOS_PROFILES+=("$name")
	done
	(( ${#PHIOS_PROFILES[@]} > 0 )) ||
		phios_die "hosts/$PHIOS_HOSTNAME.txt declares no profiles"
	return 0
}
