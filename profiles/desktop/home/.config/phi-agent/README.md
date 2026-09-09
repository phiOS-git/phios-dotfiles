# ~/.config/phi-agent/

Configuration for the phiOS AI agent subsystem (`docs/phios-agente.md`,
milestone 0). `zotac` and `razer` only — `mini` does not carry the `desktop`
profile.

Two opencode instances, separated by capability and by containment:

| | A1 — assistant | A2 — worker |
|---|---|---|
| shell | no | yes |
| writes | `output/` and `proposte/` of the active project | the code projects root |
| network | host namespace, fetch approved interactively | removed, then a whitelist (S-72) |
| memory | proposes, never writes | none |

## Files

| Path | What | Who edits |
|---|---|---|
| `env.example` | template for the local config | — |
| `~/.config/phi-agent/env` | **you create this** from the example: notes path, code root, git identity | you |
| `mounts/common.paths` | read-only base for both instances (§4.2) | repo |
| `mounts/a1.paths` | A1 perimeter (§4.3) | repo |
| `mounts/a2.paths` | A2 perimeter (§4.4) | repo |
| `mounts/never.paths` | the V-01/V-02 checklist of paths that must stay unreachable | repo |
| `a1/opencode/opencode.json` | A1 engine config — hardening defaults now, provider points at the broker (no key) from S-71 | repo |
| `a2/opencode/opencode.json` | A2 engine config — hardening defaults now, provider added at S-71 | repo |
| `tinyproxy/tinyproxy.conf` | A2 egress whitelist (S-72) | repo |

The launcher is `~/.local/bin/phi-agent-contain`. Everything — the systemd
units, `phi agent ask` — goes through it; there is no way to start an agent
outside the containment (§4.7).

## Not managed here

- The provider API key: held by `phi agent broker` outside the containment,
  read from its own file (S-71).
- The remote-surface password: a systemd credential from a root-owned file
  outside the repository (S-74).
- Personalities and projects: created by hand in milestone 0 under the A1
  data tree, `~/.local/share/phi-agent/a1/` (§8.2, §14.1). S-73.
