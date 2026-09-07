# server

`mini`. Services only, nothing graphical.

No `packages.txt` yet. The services of master plan §10 are M6 and the `[phi]`
repository it will serve over the overlay network is M1, so there is nothing
to declare there. It is listed in `hosts/mini.txt` so the place exists before
the first real service.

`system/` (S-05) carries what is already applied on `mini` by hand: the `zram`
generator sized for 4 GB of RAM and its `sysctl` companion, the `smartd`
config for the boot disk, and the two-unit `OnFailure=` drop-in pattern that
notifies on any failed systemd unit. **None of this is applied by the
installer** — `phios-install --system-diff` only shows the difference against
the machine; applying a file is a manual, `sudo`, file-by-file action.

Two things this deliberately does not carry:

- `/usr/local/bin/notify.sh`, the script both `smartd.conf` and
  `unit-failure-notify@.service` call. It lives outside the `/etc` boundary
  this mechanism covers, and the copy running on `mini` has the `ntfy.sh`
  topic baked into it at generation time — a notification topic, which no
  repository may hold (`CLAUDE.md` rule 5). The topic itself is saved
  separately on the machine, at `/etc/ntfy-topic`.
- `/dev/sdb1` in `smartd.conf`: deferred on `mini` itself, disk not ready yet
  (`mini-procedura-base.md` §17, note 9).

The `Description=`/`ExecStart=` strings here are in English, per this
repository's language rule. The unit currently running on `mini` carries the
Italian text from the original setup session, so the first `--system-diff`
against it will show that line as differing — reconcile it by editing the
machine to match, the opposite of the S-03 call to leave `Generato da
theme.sh` alone (that file had no repository-side canonical text to reconcile
against; this one does).
