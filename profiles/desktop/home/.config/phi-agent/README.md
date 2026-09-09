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
| `a1/opencode/opencode.json` | A1 engine config — provider `phi-broker` points at the broker on loopback, hardening permissions | repo |
| `a2/opencode/opencode.json` | A2 engine config — same, on the a2 broker port | repo |
| `a1/broker.example.json` | template for the broker config | — |
| `~/.config/phi-agent/<inst>/broker.json` | **you create this**: provider origin + how the key attaches (no key) | you |
| `~/.config/phi-agent/<inst>/provider-key` | **you create this**, `chmod 600`: the raw provider API key | you |
| `tinyproxy/tinyproxy.conf` | A2 egress whitelist (S-72) | repo |

## The broker (S-71, phios-agente.md §6.2)

opencode never sees the provider key. Its `phi-broker` provider talks
**in clear over loopback** to `phi agent broker`, which runs *outside* the
containment, holds the key, and adds it to the outbound request.

Set it up, per instance (a1 first):

```
cd ~/.config/phi-agent/a1
cp broker.example.json broker.json
$EDITOR broker.json          # set upstream (provider ORIGIN, no path) and auth_header/auth_value
printf '%s' 'sk-...your-key...' > provider-key && chmod 600 provider-key
$EDITOR opencode/opencode.json   # replace REPLACE-WITH-YOUR-MODEL-ID (two places)
phi agent broker --instance a1 --check     # must print a summary and exit 0
systemctl --user enable --now phi-agent-broker@a1.service
```

`opencode.json` ships assuming an **OpenAI-compatible** provider
(`@ai-sdk/openai-compatible`, requests to `/v1/chat/completions`). For a
provider that only speaks Anthropic's native `/v1/messages`, change
`provider.phi-broker.npm` to `@ai-sdk/anthropic`, set `options.baseURL` to
`http://127.0.0.1:8789` (no `/v1`), and in `broker.json` set
`auth_header` to `x-api-key`, `auth_value` to `{key}`, and add
`"anthropic-version": "2023-06-01"` to `extra_headers`.

Ports: a1 broker `127.0.0.1:8789`, a2 broker `127.0.0.1:8790`.

Consumption is logged as JSONL at
`~/.local/state/phi-agent/<inst>/broker-meter.jsonl`. The broker also
enforces a local fixed-window request limit (`rate_limit` in
`broker.json`).

## A2's network (S-72, phios-agente.md §5.1)

A2 runs with `--unshare-net`: a fresh namespace, only a down loopback, no
route anywhere. Two unix sockets in `~/.local/state/phi-agent/net/`,
bind-mounted into the container, are the only way out:

| socket | to | purpose |
|---|---|---|
| `broker-a2.sock` | `phi-agent-broker@a2` | the provider call (§6.2); created by the broker unit itself |
| `proxy.sock` | `tinyproxy` via `phi-agent-net-bridge` | everything else, filtered by `tinyproxy/whitelist` |

`phi-agent-contain` runs two `socat` forwarders inside the namespace that
turn those sockets into `127.0.0.1:8790` (broker) and `127.0.0.1:8118`
(proxy), and sets `HTTP(S)_PROXY` to the latter. A process that unsets the
proxy variables is left able to reach only the broker — never a free
network (that is V-03).

**The whitelist grows only by explicit addition.** `tinyproxy/whitelist`
ships with loopback allowed and every package registry commented out;
uncomment exactly the ones a project on this machine actually fetches from.

Enable (only when A2 is in use, from S-76):

```
systemctl --user enable --now phi-agent-proxy.service phi-agent-net-bridge.service
```

### Do this at the provider, not here

- **Set a hard spending cap on the API key.** It is the only measure that
  limits *damage* rather than probability (§6.3): a compromised agent can
  spend against the key until you revoke it, but not steal it.
- **Write the revocation procedure down now**, before you need it: the
  provider's key-management URL, and the exact steps to disable this key.
  Keep it somewhere you can reach without this machine.

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
