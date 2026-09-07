# phiOS — the state manifest (master plan §5.4, R3).
#
# $XDG_STATE_HOME/phios/manifest records every path the installer created on
# this machine, so a file that disappears from the repository can be removed
# from the home directory instead of being orphaned there forever. It is
# machine state, never versioned.
#
# One tab-separated record per line:
#
#     kind <TAB> target <TAB> source <TAB> profile <TAB> digest
#
#   kind     link | render
#   target   path relative to $HOME
#   source   path relative to the repository root
#   profile  the profile that declared it
#   digest   sha256 of the rendered file, or '-' for a symlink
#
# Paths are stored relative so the manifest stays readable and survives the
# repository being moved.

phios_manifest_path() {
	printf '%s\n' "$(phios_state_dir)/manifest"
}

# Fills PHIOS_MF_KIND / TARGET / SOURCE / PROFILE / DIGEST.
phios_manifest_load() {
	local file line kind target source profile digest
	file=$(phios_manifest_path)

	PHIOS_MF_KIND=(); PHIOS_MF_TARGET=(); PHIOS_MF_SOURCE=()
	PHIOS_MF_PROFILE=(); PHIOS_MF_DIGEST=()

	[[ -f $file ]] || return 0
	while IFS=$'\t' read -r kind target source profile digest || [[ -n $kind ]]; do
		[[ -z $kind || $kind == '#'* ]] && continue
		PHIOS_MF_KIND+=("$kind")
		PHIOS_MF_TARGET+=("$target")
		PHIOS_MF_SOURCE+=("$source")
		PHIOS_MF_PROFILE+=("$profile")
		PHIOS_MF_DIGEST+=("${digest:--}")
	done < "$file"
	return 0
}

phios_manifest_digest_of() {
	local target=$1 i
	for i in "${!PHIOS_MF_TARGET[@]}"; do
		if [[ ${PHIOS_MF_TARGET[i]} == "$target" ]]; then
			printf '%s\n' "${PHIOS_MF_DIGEST[i]}"
			return 0
		fi
	done
	printf '%s\n' '-'
}

phios_manifest_has() {
	local target=$1 i
	for i in "${!PHIOS_MF_TARGET[@]}"; do
		[[ ${PHIOS_MF_TARGET[i]} == "$target" ]] && return 0
	done
	return 1
}

# Manifest entries whose target is no longer in the plan. These are what the
# reconciliation step removes.
phios_manifest_orphans() {
	local i target
	for i in "${!PHIOS_MF_TARGET[@]}"; do
		target=${PHIOS_MF_TARGET[i]}
		if ! phios_plan_has_target "$target"; then
			phios_join_fields "${PHIOS_MF_KIND[i]}" "$target" \
				"${PHIOS_MF_SOURCE[i]}" "${PHIOS_MF_PROFILE[i]}" "${PHIOS_MF_DIGEST[i]}"
		fi
	done
	return 0
}

# Written from the applied plan, atomically, so an interrupted run leaves the
# previous manifest intact rather than a truncated one.
phios_manifest_write() {
	local file tmp dir i
	file=$(phios_manifest_path)
	dir=${file%/*}
	mkdir -p -- "$dir"
	tmp=$file.new
	{
		printf '# phios-install state manifest — machine state, not configuration.\n'
		printf '# kind\ttarget\tsource\tprofile\tdigest\n'
		for i in "${!PHIOS_PLAN_TARGET[@]}"; do
			phios_join_fields "${PHIOS_PLAN_KIND[i]}" "${PHIOS_PLAN_TARGET[i]}" \
				"${PHIOS_PLAN_SOURCE[i]}" "${PHIOS_PLAN_PROFILE[i]}" \
				"${PHIOS_PLAN_DIGEST[i]:--}"
		done
	} > "$tmp"
	mv -f -- "$tmp" "$file"
}
