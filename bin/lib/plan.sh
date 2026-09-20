# phiOS — the file plan.
#
# Every mode of phios-install works from the same plan: the set of symlinks and
# rendered files the declared profiles ask for, each compared against what is
# on the machine. --dry-run prints it, --check exits non-zero when it is not
# already satisfied, and the default mode applies it. Computing once and acting
# three ways is what makes the preview honest.
#
# Parallel arrays rather than one record array, because bash has no structs and
# the indices are the only join key needed:
#
#   PHIOS_PLAN_KIND     link | render | generate
#   PHIOS_PLAN_TARGET   path relative to $HOME
#   PHIOS_PLAN_SOURCE   path relative to the repository root (link, render), or
#                       profiles/<profile>/external.txt#<name> (generate)
#   PHIOS_PLAN_PROFILE  the profile that declared it
#   PHIOS_PLAN_DIGEST   sha256 of the rendered content, filled by the state pass
#   PHIOS_PLAN_STATE    ok | create | update | replace

phios_plan_reset() {
	PHIOS_PLAN_KIND=(); PHIOS_PLAN_TARGET=(); PHIOS_PLAN_SOURCE=()
	PHIOS_PLAN_PROFILE=(); PHIOS_PLAN_DIGEST=(); PHIOS_PLAN_STATE=()
	PHIOS_PLAN_OVERRIDES=()
}

phios_plan_index_of() {
	local target=$1 i
	for i in "${!PHIOS_PLAN_TARGET[@]}"; do
		if [[ ${PHIOS_PLAN_TARGET[i]} == "$target" ]]; then
			printf '%s\n' "$i"
			return 0
		fi
	done
	return 1
}

phios_plan_has_target() {
	phios_plan_index_of "$1" >/dev/null 2>&1
}

# A later profile may override an earlier one's file: that is how `desktop`
# specialises `base`. The override is recorded and printed rather than applied
# silently, because a shadowed file is exactly the kind of surprise --dry-run
# exists to prevent.
phios_plan_add() {
	local kind=$1 target=$2 source=$3 profile=$4 i
	if i=$(phios_plan_index_of "$target"); then
		PHIOS_PLAN_OVERRIDES+=("$target: $profile overrides ${PHIOS_PLAN_PROFILE[i]}")
		PHIOS_PLAN_KIND[i]=$kind
		PHIOS_PLAN_SOURCE[i]=$source
		PHIOS_PLAN_PROFILE[i]=$profile
		return 0
	fi
	PHIOS_PLAN_KIND+=("$kind")
	PHIOS_PLAN_TARGET+=("$target")
	PHIOS_PLAN_SOURCE+=("$source")
	PHIOS_PLAN_PROFILE+=("$profile")
	PHIOS_PLAN_DIGEST+=('-')
	PHIOS_PLAN_STATE+=('unknown')
}

# home/ is linked as-is; templates/ is rendered with the .tmpl suffix stripped.
# Both trees mirror the layout under $HOME. A third pass, after both, adds one
# generated .desktop entry per T4 declaration (bin/lib/external.sh) so a
# declared, monitored AppImage is actually launchable.
#
# That generation happens here rather than in `phi` (the Go CLI) because
# phios_manifest_write (below) rebuilds the manifest from PHIOS_PLAN_* alone
# and moves it over the old file: a record written by any other program is
# erased on the next run. Once the record is gone, phios_manifest_orphans
# never yields it and phios_plan_reconcile never removes the file it names, so
# a generated entry written by a second program would leak into
# ~/.local/share/applications permanently. The installer has to be the only
# writer for the same reason it is the only writer of a symlink or a rendered
# template.
phios_plan_build() {
	local profile dir src rel i name
	phios_plan_reset
	for profile in "${PHIOS_PROFILES[@]+"${PHIOS_PROFILES[@]}"}"; do
		dir=$PHIOS_ROOT/profiles/$profile/home
		if [[ -d $dir ]]; then
			while IFS= read -r -d '' src; do
				rel=${src#"$dir/"}
				phios_plan_add link "$rel" "${src#"$PHIOS_ROOT/"}" "$profile"
			done < <(find "$dir" \( -type f -o -type l \) -print0 | sort -z)
		fi
		dir=$PHIOS_ROOT/profiles/$profile/templates
		if [[ -d $dir ]]; then
			while IFS= read -r -d '' src; do
				rel=${src#"$dir/"}
				rel=${rel%.tmpl}
				phios_plan_add render "$rel" "${src#"$PHIOS_ROOT/"}" "$profile"
			done < <(find "$dir" -type f -name '*.tmpl' -print0 | sort -z)
		fi
	done

	# Unconditional: this plan is built purely from repository content today
	# (profiles + declarations), never from machine state, which is what makes
	# --dry-run honest. Whether the AppImage a T4 entry names is actually
	# present is not checked here; a missing artifact is a `missing` finding
	# for `phi pkg audit`, not this installer's concern.
	for i in "${!PHIOS_EXT_NAME[@]}"; do
		[[ ${PHIOS_EXT_TIER[i]} == T4 ]] || continue
		name=${PHIOS_EXT_NAME[i]}
		phios_plan_add generate \
			".local/share/applications/phios-external-$name.desktop" \
			"profiles/${PHIOS_EXT_PROFILE[i]}/external.txt#$name" \
			"${PHIOS_EXT_PROFILE[i]}"
	done
	return 0
}

# Where a symlink must point: relative, so the tree survives being moved.
phios_plan_link_value() {
	local target=$1 source=$2
	phios_relpath "$(dirname -- "$HOME/$target")" "$PHIOS_ROOT/$source"
}

# Rendered output is produced once per run and reused, so --dry-run and the
# apply that follows it are guaranteed to be talking about the same bytes.
phios_plan_rendered_path() {
	printf '%s\n' "$PHIOS_TMPDIR/render/$1"
}

# Fills PHIOS_PLAN_STATE and, for rendered and generated files, PHIOS_PLAN_DIGEST.
phios_plan_state() {
	local i kind target source abs want have rendered digest recorded
	local ext_name ext_i
	for i in "${!PHIOS_PLAN_TARGET[@]}"; do
		kind=${PHIOS_PLAN_KIND[i]}
		target=${PHIOS_PLAN_TARGET[i]}
		source=${PHIOS_PLAN_SOURCE[i]}
		abs=$HOME/$target

		if [[ $kind == link ]]; then
			want=$(phios_plan_link_value "$target" "$source")
			if [[ -L $abs ]]; then
				have=$(readlink -- "$abs")
				if [[ $have == "$want" ]]; then
					PHIOS_PLAN_STATE[i]=ok
				else
					PHIOS_PLAN_STATE[i]=update
				fi
			elif [[ -e $abs ]]; then
				PHIOS_PLAN_STATE[i]=replace
			else
				PHIOS_PLAN_STATE[i]=create
			fi
			continue
		fi

		rendered=$(phios_plan_rendered_path "$i")
		mkdir -p -- "$(dirname -- "$rendered")"
		if [[ $kind == generate ]]; then
			# source is profiles/<profile>/external.txt#<name>; the content
			# comes from the generator function, not from a template on disk.
			ext_name=${source##*#}
			ext_i=$(phios_external_index_of "$ext_name") ||
				phios_die "no external declaration for $ext_name (plan and state disagree)"
			phios_external_desktop_entry "$ext_name" "${PHIOS_EXT_REASON[ext_i]}" > "$rendered"
		else
			phios_render_template "$PHIOS_VARIANT" "$PHIOS_ROOT/$source" "$rendered"
		fi
		digest=$(phios_sha256 "$rendered")
		PHIOS_PLAN_DIGEST[i]=$digest

		if [[ -L $abs || ! -e $abs ]]; then
			# A symlink where a rendered file belongs is stale structure, not
			# content: it is replaced, not updated in place.
			if [[ -L $abs ]]; then
				PHIOS_PLAN_STATE[i]=replace
			else
				PHIOS_PLAN_STATE[i]=create
			fi
		elif [[ $(phios_sha256 "$abs") == "$digest" ]]; then
			PHIOS_PLAN_STATE[i]=ok
		else
			recorded=$(phios_manifest_digest_of "$target")
			if [[ $recorded != '-' && $recorded == $(phios_sha256 "$abs") ]]; then
				PHIOS_PLAN_STATE[i]=update
			else
				PHIOS_PLAN_STATE[i]=replace
			fi
		fi
	done
	return 0
}

# Anything the installer is about to overwrite that it did not itself write is
# moved aside first. This is what makes the run reversible: the previous file
# is still there, under one timestamped directory per run.
phios_plan_backup() {
	local target=$1 abs=$HOME/$target dest
	dest=$(phios_state_dir)/backup/$PHIOS_RUN_ID/$target
	mkdir -p -- "$(dirname -- "$dest")"
	mv -- "$abs" "$dest"
	printf '%s\n' "$dest"
}

phios_plan_apply_one() {
	local i=$1
	local kind=${PHIOS_PLAN_KIND[i]} target=${PHIOS_PLAN_TARGET[i]}
	local source=${PHIOS_PLAN_SOURCE[i]} state=${PHIOS_PLAN_STATE[i]}
	local abs=$HOME/$target want rendered backup

	if [[ $state == ok ]]; then return 0; fi
	mkdir -p -- "$(dirname -- "$abs")"

	if [[ $state == replace ]]; then
		backup=$(phios_plan_backup "$target")
		printf '  %-7s %s -> %s\n' backup "$target" "$backup"
	fi

	if [[ $kind == link ]]; then
		want=$(phios_plan_link_value "$target" "$source")
		ln -sfn -- "$want" "$abs"
	elif [[ $kind == generate ]]; then
		# Unlike render, source here is a declaration line, not a file on
		# disk (profiles/<profile>/external.txt#<name>) — chmod --reference
		# would dereference something that does not exist, so a generated
		# file gets a fixed, ordinary permission instead.
		rendered=$(phios_plan_rendered_path "$i")
		cat -- "$rendered" > "$abs"
		chmod 644 -- "$abs"
	else
		rendered=$(phios_plan_rendered_path "$i")
		cat -- "$rendered" > "$abs"
		chmod --reference="$PHIOS_ROOT/$source" -- "$abs"
	fi
	printf '  %-7s %s\n' "$state" "$target"
	return 0
}

# Reconciliation (R3): a path the manifest records but the plan no longer
# declares is removed, provided it is still the file the installer wrote. If it
# has been changed by hand it is left alone and reported — deleting a file the
# user edited would be the worst possible reading of "idempotent".
phios_plan_reconcile() {
	local kind target source profile digest abs removed=0
	while IFS=$'\t' read -r kind target source profile digest; do
		[[ -n $kind ]] || continue
		abs=$HOME/$target
		if [[ ! -e $abs && ! -L $abs ]]; then
			continue
		fi
		if [[ $kind == link ]]; then
			if [[ -L $abs ]]; then
				rm -- "$abs"
				printf '  %-7s %s\n' remove "$target"
				removed=$((removed + 1))
			else
				phios_warn "not removing $target: no longer a symlink"
			fi
			continue
		fi
		if [[ -f $abs && ! -L $abs && $digest != '-' && $(phios_sha256 "$abs") == "$digest" ]]; then
			rm -- "$abs"
			printf '  %-7s %s\n' remove "$target"
			removed=$((removed + 1))
		else
			phios_warn "not removing $target: modified since it was written"
		fi
	done < <(phios_manifest_orphans)
	if (( removed == 0 )); then phios_out '  nothing'; fi
	return 0
}
