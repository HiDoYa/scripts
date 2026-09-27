Secrets + pkg lists → restic repo on NAS (SFTP). Offsite via Synology Hyper Backup.

Setup:
- `brew install restic resticprofile`
- `ssh store` alias w/ key auth; DSM: Control Panel → File Services → FTP → enable SFTP
- Password in keychain: `security add-generic-password -a restic -s restic-backup -w` (also save in 1Password; lost pw = lost backups)
- `rp init`: create repo
- `rp schedule`: install launchd agent; backups then run automatically (Sat 15:00, while logged in) incl. retention/prune. Re-run after changing schedule in `profiles.yaml`; `rp unschedule` to remove

```
alias rp='resticprofile -c $SCRIPTS_DIR/backup/profiles.yaml -n secrets'
```

Usage:
- `rp backup`, `rp snapshots`, `rp diff <id1> <id2>`, `rp ls latest`
- Restore one path: `rp restore latest --target /tmp/r --include ~/.ssh`
- Test scheduled job now: `launchctl start local.resticprofile.secrets.backup`
- Logs (scheduled runs): `~/Library/Logs/resticprofile.log`
