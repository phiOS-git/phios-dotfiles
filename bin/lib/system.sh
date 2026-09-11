# phiOS — the /etc boundary (master plan §5.5, R7, I-09).
#
# System material lives in profiles/<name>/system/, mirroring the absolute path
# it belongs at, and the installer NEVER applies it. --system-diff shows the
# difference and stops there; applying it is a user action, with sudo, file by
# file, after reading that difference.
#
# The diff is produced with `git diff --no-index`, which is already in the
# dependency budget and gives the same output the user reads everywhere else.
#
# The two reporters at the end of this file are here for the same reason: a
# systemd unit and a manual step are declared by a profile and performed by the
# user, never by the installer. Same boundary, different material.

# Fills PHIOS_SYSTEM_FILES with "profile<TAB>source<TAB>destination" records.
phios_system_collect() {
	local profile dir src rel
	PHIOS_SYSTEM_FILES=()
	for profile in "${PHIOS_PROFILES[@]+"${PHIOS_PROFILES[@]}"}"; do
		dir=$PHIOS_ROOT/profiles/$profile/system
		[[ -d $dir ]] || continue
		while IFS= read -r -d '' src; do
			rel=${src#"$dir/"}
			PHIOS_SYSTEM_FILES+=("$(phios_join_fields "$profile" "$src" "/$rel")")
		done < <(find "$dir" -type f -print0 | sort -z)
	done
	return 0
}

# Read-only and unprivileged by design: a file the current user cannot read is
# reported as unknown rather than escalated or treated as a difference.
phios_system_diff() {
	local record profile src dest left output status differing=0 unreadable=0

	phios_system_collect
	if (( ${#PHIOS_SYSTEM_FILES[@]} == 0 )); then
		phios_out 'no system material declared'
		return 0
	fi

	for record in "${PHIOS_SYSTEM_FILES[@]}"; do
		IFS=$'\t' read -r profile src dest <<< "$record"
		if [[ -e $dest && ! -r $dest ]]; then
			phios_out "unreadable  $dest  (needs privilege; declared by $profile)"
			unreadable=$((unreadable + 1))
			continue
		fi
		left=/dev/null
		if [[ -f $dest ]]; then left=$dest; fi
		status=0
		output=$(git --no-pager diff --no-index --exit-code -- "$left" "$src") || status=$?
		case $status in
			0) ;;
			1)
				differing=$((differing + 1))
				phios_out ""
				phios_out "$dest  (declared by $profile; left: machine, right: repository)"
				phios_out "$output"
				;;
			*) phios_warn "diff failed for $dest (exit $status)" ;;
		esac
	done

	phios_out ''
	phios_out "system files declared: ${#PHIOS_SYSTEM_FILES[@]}, differing: $differing, unreadable: $unreadable"
	phios_out 'nothing above was applied; applying is a user action, with sudo, file by file'
	if (( differing > 0 )); then return 1; fi
	return 0
}

# Declared systemd units. The installer prints them and stops: enabling a unit
# is a user action (R8). It deliberately does not query systemd either, so
# --check reports no service drift; that gap does not close, at S-05 or ever —
# querying systemd state is exactly the boundary this installer does not cross.
phios_services_report() {
	local profile scope file unit any=0
	for scope in user system; do
		for profile in "${PHIOS_PROFILES[@]+"${PHIOS_PROFILES[@]}"}"; do
			file=$PHIOS_ROOT/profiles/$profile/services-$scope.txt
			while IFS= read -r unit; do
				printf '  %-6s %s  (%s)\n' "$scope" "$unit" "$profile"
				any=1
			done < <(phios_read_list "$file")
		done
	done
	if (( any == 0 )); then
		phios_out '  none declared'
	else
		phios_out '  enable these yourself; this script never runs systemctl'
	fi
	return 0
}

# Declared manual steps (profiles/<name>/manual.txt). Same contract as the
# services above and the reason they share this file: the installer states what
# has to happen and performs none of it. These are the one-off actions that are
# neither a package, nor a file, nor a systemd unit — the yazi git plugin is the
# first, and the reason install.sh silently left a known gap (C-10).
#
# Like services, they are printed and never checked, so --check says nothing
# about whether they have been done.
phios_manual_report() {
	local profile file step any=0
	for profile in "${PHIOS_PROFILES[@]+"${PHIOS_PROFILES[@]}"}"; do
		file=$PHIOS_ROOT/profiles/$profile/manual.txt
		while IFS= read -r step; do
			printf '  %s\n' "$step"
			any=1
		done < <(phios_read_list "$file")
	done
	if (( any == 0 )); then
		phios_out '  none declared'
	else
		phios_out '  run these yourself; this script never runs them'
	fi
	return 0
}
