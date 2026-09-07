# phiOS — package planning.
#
# Only `pacman` is used, and only for T0 repositories: AUR and manual builds
# are out of scope while Q-01 is deferred. Own packages come from the [phi]
# repository built in M1 and are never installed from here.
#
# Reads are unprivileged (`pacman -T`); the single privileged call lives in
# phios_packages_install and runs only in apply mode.

# Fills PHIOS_PACKAGES with the union of the profiles' packages.txt, in
# declaration order, deduplicated.
phios_packages_collect() {
	local profile pkg seen=''
	PHIOS_PACKAGES=()
	for profile in "${PHIOS_PROFILES[@]+"${PHIOS_PROFILES[@]}"}"; do
		while IFS= read -r pkg; do
			case $seen in
				*"|$pkg|"*) continue ;;
			esac
			seen+="|$pkg|"
			PHIOS_PACKAGES+=("$pkg")
		done < <(phios_read_list "$PHIOS_ROOT/profiles/$profile/packages.txt")
	done
	return 0
}

phios_pacman_available() {
	command -v -- pacman >/dev/null 2>&1
}

# Fills PHIOS_PACKAGES_MISSING with the declared packages that are not
# satisfied. `pacman -T` (deptest) is read-only, needs no privilege, and
# understands virtual providers, which a plain `-Qq` name match does not.
# It exits non-zero when something is unsatisfied, which is the normal case.
phios_packages_missing() {
	local output=''
	PHIOS_PACKAGES_MISSING=()
	if (( ${#PHIOS_PACKAGES[@]} == 0 )); then return 0; fi
	if ! phios_pacman_available; then return 0; fi
	output=$(pacman -T -- "${PHIOS_PACKAGES[@]}" || true)
	[[ -n $output ]] || return 0
	mapfile -t PHIOS_PACKAGES_MISSING <<< "$output"
	return 0
}

# The one privileged operation in the installer. Never reached from --dry-run,
# --check or --system-diff.
phios_packages_install() {
	if (( ${#PHIOS_PACKAGES_MISSING[@]} == 0 )); then return 0; fi
	phios_out "running: sudo pacman -S --needed -- ${PHIOS_PACKAGES_MISSING[*]}"
	sudo pacman -S --needed -- "${PHIOS_PACKAGES_MISSING[@]}"
}
