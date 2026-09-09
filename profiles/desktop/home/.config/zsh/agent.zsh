# phiOS — AI agent shell helpers (desktop profile, S-76).
#
# `phi-code [DIR]` starts a contained A2 opencode session (the worker
# agent, docs/phios-agente.md §3.1). This is the day-to-day replacement
# for running opencode unconfined — the S-76 transition.
#
# Inside the session there are NO SSH keys, NO gpg, NO push to remotes:
# A2 edits and commits locally, and publishing is your action afterward
# (§4.4, ADR 089). Network is the S-72 whitelist only.
#
# DIR defaults to $PWD and must be inside PHI_AGENT_CODE_ROOT
# (~/.config/phi-agent/env), which is the only tree A2 can write.

phi-code() {
	emulate -L zsh
	local dir=${1:-$PWD}
	dir=${dir:A}

	local code_root=${PHI_AGENT_CODE_ROOT:-$HOME/code}
	code_root=${code_root:A}
	if [[ $dir != $code_root && $dir != $code_root/* ]]; then
		print -u2 "phi-code: $dir is not inside PHI_AGENT_CODE_ROOT ($code_root)"
		print -u2 "phi-code: A2 can only write there — move the project or adjust ~/.config/phi-agent/env"
		return 1
	fi
	if ! command -v phi-agent-contain >/dev/null 2>&1; then
		print -u2 "phi-code: phi-agent-contain not found — run bin/phios-install"
		return 1
	fi

	# The container sees the code root at /home/agent/code; translate the
	# host path so opencode opens the right directory inside.
	local rel=${dir#$code_root}
	rel=${rel#/}
	( cd "$dir" && phi-agent-contain a2 -- sh -c 'cd "/home/agent/code/$1" 2>/dev/null || cd /home/agent/code; exec opencode' phi-code "$rel" )
}

# `phi-ask` is just a shorter alias for the inline A1 question (§10.2).
alias phi-ask='phi agent ask'
