# phiOS — template rendering against the design tokens.
#
# design/ is the single source of every colour, font, size, radius and motion
# value (I-05). A template is rendered by sourcing the token files for one
# variant and substituting only the PHI_* names they export — never the whole
# environment, so a `$PATH` or `$HOME` inside a configuration file survives
# untouched.
#
# The token files themselves arrive at S-02, and design/adapters.txt will then
# own destinations and reload commands. Until they exist, a profile that ships
# a template is a hard error rather than a silent half-render.

# The active variant is runtime state owned by the settings panel (§5.6). The
# installer only reads it, and falls back to dark, which is the default variant.
phios_variant() {
	local file variant=${PHIOS_VARIANT:-}
	if [[ -z $variant ]]; then
		file=$(phios_runtime_dir)/theme-variant
		if [[ -r $file ]]; then read -r variant < "$file" || variant=''; fi
	fi
	printf '%s\n' "${variant:-dark}"
}

# Fills PHIOS_TOKEN_FILES for a variant, or fails with the reason.
phios_tokens_files() {
	local variant=$1 common variant_file
	common=$PHIOS_ROOT/design/tokens.common.sh
	variant_file=$PHIOS_ROOT/design/tokens.$variant.sh

	PHIOS_TOKEN_FILES=()
	[[ -f $common ]] || return 1
	[[ -f $variant_file ]] || return 2
	PHIOS_TOKEN_FILES=("$common" "$variant_file")
	return 0
}

phios_tokens_require() {
	local variant=$1 status=0
	phios_tokens_files "$variant" || status=$?
	case $status in
		0) return 0 ;;
		1) phios_die 'design/tokens.common.sh is missing; templates cannot be rendered (S-02)' ;;
		2) phios_die "design/tokens.$variant.sh is missing; unknown theme variant: $variant" ;;
	esac
}

# Renders SRC to DEST for VARIANT. Token files are sourced in a subshell so
# nothing they define leaks into the installer's own environment.
phios_render_template() {
	local variant=$1 src=$2 dest=$3
	phios_tokens_require "$variant"
	(
		set -a
		local file
		for file in "${PHIOS_TOKEN_FILES[@]}"; do
			# shellcheck disable=SC1090
			. "$file"
		done
		set +a

		local shell_format='' name
		for name in $(compgen -A variable); do
			case $name in
				PHI_*) shell_format+="\$$name " ;;
			esac
		done

		envsubst "$shell_format" < "$src" > "$dest"
	)
}
