# phiOS — declared non-official software.
#
# profiles/<profile>/external.txt declares everything at tier TC, T2, T3 or T4
# (the ladder is rule 1 in the workspace AGENTS.md). T0 and T1 stay in
# packages.txt: a [phi] package already comes from a configured pacman
# repository, so pacman already installs, tracks and removes it, and a second
# declaration path here would be a mistake, not a convenience.
#
# This library only parses and reports. It never fetches or installs anything:
# downloading and running an arbitrary artifact from the installer is the exact
# risk the tier ladder exists to bound. The declaration is the record; the
# user installs. Reconciling what is actually on the machine against what is
# declared here is `phi pkg audit`'s job, in the Go CLI.
#
# One record per line, six `|`-separated fields, each trimmed of surrounding
# whitespace — see profiles/README.md for the authoritative format. A second
# parser, in `phi` (Go), is written against that exact spec, so a behaviour
# change here is a change there too.
#
# Parallel arrays, the same shape plan.sh and packages.sh already use:
#
#   PHIOS_EXT_NAME      matches ^[A-Za-z0-9._-]+$ — also a generated filename
#   PHIOS_EXT_TIER      TC | T2 | T3 | T4
#   PHIOS_EXT_SOURCE    where it comes from (a URL, a flathub id, an image)
#   PHIOS_EXT_REF       pinned version, commit or digest — never `latest`
#   PHIOS_EXT_SHA       '-' or 64 lowercase hex characters, tier-dependent
#   PHIOS_EXT_REASON    why it is here at all; load-bearing for a yearly prune
#   PHIOS_EXT_PROFILE   the profile that declared it
#
# PHIOS_EXT_ERRORS and PHIOS_EXT_OVERRIDES collect human-readable lines rather
# than aborting: --check has to be able to report a malformed declaration
# rather than die on it.

# Trims surrounding whitespace from one field. Identical to the trim
# phios_read_list already applies to a whole line, applied per field instead.
phios_external_trim() {
	local s=$1
	s=${s#"${s%%[![:space:]]*}"}
	s=${s%"${s##*[![:space:]]}"}
	printf '%s\n' "$s"
}

phios_external_index_of() {
	local name=$1 i
	for i in "${!PHIOS_EXT_NAME[@]}"; do
		if [[ ${PHIOS_EXT_NAME[i]} == "$name" ]]; then
			printf '%s\n' "$i"
			return 0
		fi
	done
	return 1
}

# A duplicate name from a later profile overrides the earlier record — the
# same idiom phios_plan_add already uses for a shadowed file, so the
# installer has one override behaviour rather than two.
phios_external_add() {
	local name=$1 tier=$2 source=$3 ref=$4 sha=$5 reason=$6 profile=$7 i
	if i=$(phios_external_index_of "$name"); then
		PHIOS_EXT_OVERRIDES+=("$name: $profile overrides ${PHIOS_EXT_PROFILE[i]}")
		PHIOS_EXT_TIER[i]=$tier
		PHIOS_EXT_SOURCE[i]=$source
		PHIOS_EXT_REF[i]=$ref
		PHIOS_EXT_SHA[i]=$sha
		PHIOS_EXT_REASON[i]=$reason
		PHIOS_EXT_PROFILE[i]=$profile
		return 0
	fi
	PHIOS_EXT_NAME+=("$name")
	PHIOS_EXT_TIER+=("$tier")
	PHIOS_EXT_SOURCE+=("$source")
	PHIOS_EXT_REF+=("$ref")
	PHIOS_EXT_SHA+=("$sha")
	PHIOS_EXT_REASON+=("$reason")
	PHIOS_EXT_PROFILE+=("$profile")
	return 0
}

# Validates one already-split record. Sets PHIOS_EXT_ERROR to the first
# problem found and returns 1, or clears it and returns 0. One message per
# record keeps --check readable: a line with several problems still gets
# fixed one pass at a time. The rules below are normative for every parser
# reading external.txt — this one and the Go one in `phi` alike; the wording
# of the message is not part of that contract, only which lines are accepted.
phios_external_validate() {
	local name=$1 tier=$2 source=$3 ref=$4 sha=$5 reason=$6
	PHIOS_EXT_ERROR=''

	if [[ ! $name =~ ^[A-Za-z0-9._-]+$ ]]; then
		PHIOS_EXT_ERROR="invalid name '$name' (must match ^[A-Za-z0-9._-]+\$)"
		return 1
	fi

	case $tier in
		T0|T1)
			PHIOS_EXT_ERROR="tier $tier belongs in packages.txt, not external.txt"
			return 1
			;;
		TC|T2|T3|T4) ;;
		*)
			PHIOS_EXT_ERROR="unknown tier '$tier' (expected TC, T2, T3 or T4)"
			return 1
			;;
	esac

	if [[ -z $source ]]; then
		PHIOS_EXT_ERROR='source is empty'
		return 1
	fi

	if [[ -z $ref ]]; then
		PHIOS_EXT_ERROR='ref is empty'
		return 1
	fi
	if [[ $ref == latest ]]; then
		PHIOS_EXT_ERROR="ref must be pinned, not 'latest'"
		return 1
	fi
	if [[ $tier == TC && $ref != sha256:* ]]; then
		PHIOS_EXT_ERROR='tier TC requires ref to start with sha256: (an image digest, never a tag)'
		return 1
	fi

	case $tier in
		T4)
			if [[ ! $sha =~ ^[0-9a-f]{64}$ ]]; then
				PHIOS_EXT_ERROR='tier T4 requires sha256 to be 64 lowercase hex characters'
				return 1
			fi
			;;
		T3)
			if [[ $sha != '-' && ! $sha =~ ^[0-9a-f]{64}$ ]]; then
				PHIOS_EXT_ERROR="tier T3 requires sha256 to be '-' or 64 lowercase hex characters"
				return 1
			fi
			;;
		T2|TC)
			if [[ $sha != '-' ]]; then
				PHIOS_EXT_ERROR="tier $tier requires sha256 to be '-' (its own manager provides integrity)"
				return 1
			fi
			;;
	esac

	if [[ -z $reason ]]; then
		PHIOS_EXT_ERROR='reason is empty'
		return 1
	fi

	return 0
}

# Parses one external.txt, APPENDING to PHIOS_EXT_* and PHIOS_EXT_ERRORS.
# Never aborts: --check has to be able to report a malformed declaration
# rather than die on it. A missing file is not an error, matching
# phios_read_list — most profiles declare nothing.
phios_external_parse_file() {
	local file=$1 profile=$2 line seps
	local name tier source ref sha reason
	local -a fields

	while IFS= read -r line; do
		# Count separators rather than trust the field count bash's `read`
		# produces: a line ending in `|` makes `read -a` silently drop the
		# trailing empty field, which would accept a 7-field line as 6. The
		# Go parser splits on `|` directly and would reject the same line, so
		# counting separators is what keeps the two parsers in agreement.
		seps=${line//[^|]/}
		if (( ${#seps} != 5 )); then
			PHIOS_EXT_ERRORS+=("$file: expected 6 fields, got $(( ${#seps} + 1 )): $line")
			continue
		fi

		IFS='|' read -r -a fields <<< "$line"
		name=$(phios_external_trim "${fields[0]}")
		tier=$(phios_external_trim "${fields[1]}")
		source=$(phios_external_trim "${fields[2]}")
		ref=$(phios_external_trim "${fields[3]}")
		sha=$(phios_external_trim "${fields[4]}")
		# A trailing empty final field is the one bash's `read -a` drops (the
		# separator count above already proved it exists), so it is read back
		# with a default rather than indexed directly under `set -u`.
		reason=$(phios_external_trim "${fields[5]:-}")

		if ! phios_external_validate "$name" "$tier" "$source" "$ref" "$sha" "$reason"; then
			PHIOS_EXT_ERRORS+=("$file: $PHIOS_EXT_ERROR: $line")
			continue
		fi

		phios_external_add "$name" "$tier" "$source" "$ref" "$sha" "$reason" "$profile"
	done < <(phios_read_list "$file")
	return 0
}

# Fills PHIOS_EXT_* with the union of the profiles' external.txt, in
# declaration order, later profiles overriding earlier ones by name.
phios_external_collect() {
	local profile
	PHIOS_EXT_NAME=(); PHIOS_EXT_TIER=(); PHIOS_EXT_SOURCE=(); PHIOS_EXT_REF=()
	PHIOS_EXT_SHA=(); PHIOS_EXT_REASON=(); PHIOS_EXT_PROFILE=()
	PHIOS_EXT_ERRORS=(); PHIOS_EXT_OVERRIDES=()
	for profile in "${PHIOS_PROFILES[@]+"${PHIOS_PROFILES[@]}"}"; do
		phios_external_parse_file "$PHIOS_ROOT/profiles/$profile/external.txt" "$profile"
	done
	return 0
}

# Prints the section body for phios_report: the declared entries, and any
# parse errors or overrides found while collecting them. It deliberately never
# checks whether anything is actually installed — enumerating Flatpak,
# AppImage or container state on the machine is `phi pkg audit`'s job in the
# Go CLI, and duplicating it here would be a second implementation of the
# same thing.
phios_external_report() {
	local i line

	if (( ${#PHIOS_EXT_NAME[@]} == 0 )); then
		phios_out '  none declared'
	else
		for i in "${!PHIOS_EXT_NAME[@]}"; do
			phios_out "  ${PHIOS_EXT_TIER[i]}  ${PHIOS_EXT_NAME[i]}  ${PHIOS_EXT_REF[i]}  (${PHIOS_EXT_PROFILE[i]})"
		done
	fi

	if (( ${#PHIOS_EXT_OVERRIDES[@]} > 0 )); then
		phios_out '  overrides'
		for line in "${PHIOS_EXT_OVERRIDES[@]}"; do
			phios_out "    $line"
		done
	fi

	if (( ${#PHIOS_EXT_ERRORS[@]} > 0 )); then
		phios_out '  errors'
		for line in "${PHIOS_EXT_ERRORS[@]}"; do
			phios_out "    $line"
		done
	fi
	return 0
}
