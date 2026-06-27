# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/).

## 2026-06-27 (continued 8)

### Changed

- `borgmatic` is now a thin wrapper around `borgmatic.bin` (the pip-installed binary), allowing the entrypoint to be intercepted cleanly without any behaviour change for users.

## 2026-06-27 (continued 7)

### Changed

- Reorder Dockerfile layers for better cache utilisation: `apk` packages now install before S6 overlay is added, and S6 is extracted in its own `RUN` step. Previously a S6 version bump invalidated the entire apk + pip chain; now each concern caches independently.
- Use `--mount=type=cache,id=apk-${TARGETARCH}` for the `apk` step (consistent with the existing pip cache mount).

## 2026-06-27 (continued 6)

### Fixed

- `renovate.json`: add `versioningTemplate: "loose"` to the S6 overlay custom manager. S6 uses 4-part version numbers (`3.2.0.2`) which aren't valid semver — without `loose` versioning Renovate silently skips S6 updates.

### Changed

- S6 overlay updated from `3.2.0.2` to `3.2.3.0`.

## 2026-06-27 (continued 5)

### Fixed

- `renovate.json`: constrain `PYTHON_VERSION` updates to major.minor only (`/^\d+\.\d+$/`), same as `ALPINE_VERSION`. Prevents Renovate proposing pre-release or Windows-variant tags like `3.15.0b3-windowsservercore-ltsc2025` which don't exist as valid Alpine-based Python images.

## 2026-06-27 (continued 4)

### Fixed

- `.drone.yml`: Drone tags file now written as a single comma-separated line (`latest,2.1.6-1.4.4`) rather than one tag per line. `thegeeklab/drone-docker-buildx` treated the entire file content as one string, causing an invalid tag error (`latest\n2.1.6-1.4.4`).

## 2026-06-27 (continued 3)

### Added

- `data/borgscripts/docker-stop.sh`: stops containers carrying a configurable label (`backup` by default) before a borgmatic run. Configurable label key and stop timeout. Requires `DOCKERCLI=true` and `docker.sock` mounted.
- `data/borgscripts/docker-start.sh`: starts a single compose stack after a borgmatic run using `docker compose start` (not `up -d`, so no unintended recreates). Configurable compose project directory. Requires `DOCKERCLI=true` and `docker.sock` mounted.
- `data/borgscripts/redis-backup.sh`: triggers `BGSAVE` on a Redis container and polls until the save completes before borgmatic runs. Configurable container name and timeout. The resulting `dump.rdb` is then included in borgmatic's normal source directory sweep.
- README: new "Example borgscripts" section covering all three scripts — configuration variables, label setup, borgmatic wiring, Docker requirements, and a note on AOF mode. New "Native database backup" section covering borgmatic's built-in PostgreSQL, MariaDB, MongoDB, and SQLite support.

## 2026-06-27 (continued 2)

### Added

- End-to-end CI tests that run borgmatic against a real Borg repository: full backup/restore cycle (repo-create → create → list → extract → verify file contents), `${VAR}` env var expansion in borgmatic config, and `encryption_passcommand` via a mounted secrets file.
- CI test that `borgmatic config validate` rejects invalid config with a non-zero exit code.

### Changed

- `base-fullbuild/` directory removed — all contents moved to repo root (`Dockerfile`, `requirements.txt`, `.env.template`, `data/`, `root/`) to match upstream structure. All CI, Drone, Renovate, and README references updated.
- `sync-drone-tags.yml` GitHub Actions workflow removed — redundant since `.drone.yml` now generates tags dynamically from `requirements.txt` at build time.
- Drone lint step removed — Hadolint and ShellCheck already run in GitHub Actions CI on every PR.

## 2026-06-27 (continued)

### Added

- `init-envfile` S6 oneshot service — processes `FILE__VARNAME` environment variables (LinuxServer.io convention) by reading the referenced file and writing its content into the S6 container environment before any other service starts. Complements the existing `BORG_PASSPHRASE_FILE` / `*_FILE` expansion. Dependency chain is now: `init-envfile → init-custom-packages → init-custom-scripts → init-config-end → svc-cron`.
- Renovate tracking for `ALPINE_VERSION` and `PYTHON_VERSION` — base image versions extracted as `ARG`s so Renovate can open PRs for each independently.
- Log rotation example (`logging: driver: local`) added to `docker-compose.yml` comments.
- `.gitignore` excluding `.claude` directory.

### Changed

- Base image updated from `python:3.14-alpine3.23` to `python:3.14-alpine3.24`.
- `S6_CMD_WAIT_FOR_SERVICES_MAXTIME` reverted to `0` (unlimited) — 30s could abort startup when `EXTRA_PKGS` installs large packages on a slow network.
- `docker-compose.restore.yml` — `/RestoreMount` renamed to `/mnt/restore` (consistent with main compose and README); `BORG_PASSPHRASE` added (required to decrypt repo when mounting archives); shell changed from `/bin/sh` to `/bin/bash`.
- `VOLUME_RESTORE` renamed to `BORG_RESTORE` in restore compose and `.env.template` (consistent with `BORG_*` naming convention).
- `docker-compose.yml` — expanded commented examples covering `BORG_SOURCE_*`, `BORG_REPO`, `BORG_HEALTHCHECK_URL`, `CRON`/`CRON_COMMAND`, `EXTRA_CRON` multi-line syntax, borgscripts volume, docker.sock, and `custom-cont-init.d`.
- Borgmatic config examples (`config.yaml`, `config.yaml.example`, `config.full.yaml.example`) updated to borgmatic 2.x format — deprecated `location:`, `storage:`, `retention:`, `consistency:` sections removed; all keys promoted to top level; `repositories:` now uses `{path:, label:}` objects; `checks:` uses `{name:, frequency:}` objects.
- All hook examples updated from deprecated `before_everything`/`after_everything`/`on_error` keys to the borgmatic 2.x `commands:` syntax with `before:`/`after:` timing levels and `states:` filters.
- Hook script examples (`before-backup.example`, `after-backup.example`, `failed-backup.example`) rewritten — label-based container selection (`docker ps -f label=backup | xargs --no-run-if-empty docker stop`), `docker compose start` for restart, `#!/bin/bash` shebangs replacing `with-contenv sh`.
- README — added Configuration section (example files table, env var expansion, Healthchecks.io integration); Hook scripts section (label-based stop pattern, borgscripts volume, backing up Docker compose files); log rotation under Logging; expanded restore section with shell access walkthrough. All hook examples updated to `commands:` syntax.
- `.drone.yml` — tags now generated dynamically from `requirements.txt` via a prepare step writing a `.tags` file; `no_cache: false` and `compress: true` removed; `PUSHRM_SHORT` updated.

## 2026-06-27

### Added

- `borgmatic-start` wrapper script — forwards SIGTERM/INT/HUP to borgmatic when the container is stopped, allowing in-progress backups to exit cleanly and release repository locks. The default cron command now uses `borgmatic-start` instead of `borgmatic` directly. A warning is printed at startup if the active crontab calls `borgmatic` directly.
- `/custom-cont-init.d/` support — mount a directory of `.sh` scripts that run after package installation but before cron starts, in filename order. Was previously documented but not wired up.
- `svc-cron-log` S6 logging pipeline — prefixes every log line from crond and borgmatic with an ISO timestamp before writing to Docker's log driver.
- `init-custom-scripts` S6 oneshot service — the new service that executes custom init scripts, inserted between `init-custom-packages` and `init-config-end` in the dependency chain.
- `svc-cron/timeout-down` — tells S6 to wait 5 seconds for crond to exit after SIGTERM before escalating to SIGKILL.
- Renovate tracking for `S6_OVERLAY_VERSION` — automatic update PRs when new S6 releases drop.
- `stop_grace_period: 10m` added to `docker-compose.yml`.
- State volume (`/root/.local/state/borgmatic`) added to `docker-compose.yml` and `.env.template`.
- `restart: unless-stopped` added to `docker-compose.yml`.
- `version:` field removed from both compose files (deprecated in Compose v2).

### Changed

- `svc-cron/run` — `compgen -e` replaces `set | grep` for safe secret variable expansion (immune to multi-line values); indirect expansion `${!var}` replaces `eval`; `EXTRA_CRON` append now uses `printf` to guarantee a leading newline; debug labels corrected to show "Before"/"After"; `debug_secrets()` function deduplicated; dead `CRON="${CRON:-...}"` branch removed (S6 treats empty env vars as unset).
- Default cron fallback — when no `CRON` env var and no `crontab.txt` is present, the container now falls back to a default schedule of `0 1 * * *` with a log message, rather than silently failing to open `crontab.txt`.
- `init-custom-packages/run` — `EXTRA_PKGS` now split via `read -ra` to avoid fragile unquoted word splitting; `--no-cache` added to both `apk add` calls.
- `svc-cron/finish` — now distinguishes clean stop, error exit, and signal crash with a specific log message for each.
- `Dockerfile` — removed `TERM=xterm` from baked-in `ENV`; `S6_CMD_WAIT_FOR_SERVICES_MAXTIME` raised from `0` (infinite) to `30000` ms; S6 tarballs cleaned up after extraction; `bash-doc` removed; redundant second `apk upgrade` removed.
- README rewritten to reflect current architecture, S6 features, signal handling, secret files, scheduling modes, Apprise notifications, and restore procedure.
- `.env.template` — removed deprecated `VOLUME_DOT_BORGMATIC`; added `VOLUME_BORGMATIC_STATE`.

### Fixed

- CI expanded from a bare build check to a full test suite covering binary versions, config validation, S6/cron configuration, secret file expansion, custom init scripts, timestamped logging, and SIGTERM signal forwarding.

## 2021-05-25

### Changed

- Updated Borgmatic from v1.6.0 to v1.6.1. Read the [change notes](https://github.com/borgmatic-collective/borgmatic/releases/tag/1.6.1)
- Updated Dockerfile to chmod script on COPY rather than via a separate chmod step. 
- Updated dependencies. 

## 2021-04-26

### Changed

- Updated Borgmatic from v1.5.24 to v1.6.0. Read the [change notes](https://github.com/borgmatic-collective/borgmatic/releases/tag/1.6.0)

## 2021-04-05

### Changed

- Updated alpine to 3.15.4
 
## 2021-03-29

### Changed

- Updated alpine to 3.15.3

## 2021-03-14

### Changed

- Updated to latest dependencies.
- Updated Changelog

## [1.5.24-1.2.0] - 2021-11-22

### Changed

- Updated Borg backup from v1.1.17 to v1.2.0.
- Updated tags to better follow both versions of Borg and Borgmatic

## [1.5.23] - 2021-02-10

### Changed

- Updated Borgmatic to 1.5.23

## [1.5.22] - 2021-01-05
  
### Changed
 
- Updated to latest dependencies.

## [1.5.20] - 2021-10-11
  
### Changed
 
- Updated to latest dependencies.

## [Liveinstall] - 2021-10-11
  
### Changed

- Updated Dockerfile based on the latest version.

## [DockerCLI] - 2021-10-11
  
### Changed

- Updated Dockerfile based on the latest version.

## [1.5.19] - 2021-10-11
  
### Changed
 
- Updated to latest dependencies


## [Liveinstall] - 2021-09-10
  
### Added

- Created Dockerfile based on the latest version.
- `Docker-cli` is installed on startup by default with `LIVEINSTALL` env variable available if you wish to customise.
- Added [wtfc](https://github.com/typekpb/wtfc) script to make sure there is an internet connection prior to running live install.

## [DockerCLI](https://hub.docker.com/layers/164828805/modem7/borgmatic-docker/dockercli/images/sha256-992eeb053c59ad5cc953a4e96c3d702d32bb903b419463a27df9002e8a7f58fd?context=repo) - 2021-09-10
  
### Added

- Created Dockerfile based on the latest version.
- Baked in `docker-cli` during the install

## [1.5.18](https://hub.docker.com/layers/164830365/modem7/borgmatic-docker/1.5.18/images/sha256-12ad2daab8a13192908d9b5f37d7a5c0df1e76c87598bbf330f27c0fc11f78c4?context=repo) - 2021-09-10
  
### Added
 
- Updated readme
- Updated [guide](https://www.modem7.com/books/docker-backup/page/backup-docker-using-borgmatic)
- Updated to latest dependencies
- Added additional builds for docker-cli both as liveinstall and baked in

### Changed
  
- Pinned dependency versions
  - `pip` to `21.2.4`
  - `borgbackup` to `1.1.17`
  - `borgmatic` to `1.5.18`
  - `llfuse` to `1.4.1`

- Added `LIVEINSTALL` env variable to [liveinstall](https://hub.docker.com/layers/164828783/modem7/borgmatic-docker/liveinstall/images/sha256-9d53d2f4f00b7cf1e468db4a1ec10ac3698e0e61a7c0e666d6ac7954fc7f3aa2?context=repo) tag to allow for custom installation options
  - If `LIVEINSTALL` is not declared in your compose file then `docker-cli` gets installed by default. 

- Added Changelog.
 
## [1.5.14](https://hub.docker.com/layers/164832068/modem7/borgmatic-docker/1.5.14/images/sha256-f80eaa0fd3a9e1b42d91fb4fb677d07a43bdcfbc87db43f5a614b2de47b50209?context=repo) - 2021-09-10
 
### Added
- Cloned [B3vis/Borgmatic](https://hub.docker.com/r/b3vis/borgmatic) repo
  
### Changed

- Updated readme
- Created [guide](https://www.modem7.com/books/docker-backup/page/backup-docker-using-borgmatic)
- Added dependabot
- Added requirements.txt
- Created drone multiarch pipeline
- Added hadolint file
- List what package versions are installed in STDOUT

### Fixed

- Pinned dependency versions
  - `pip` to `20.2.4`
  - `borgbackup` to `1.1.16`
  - `borgmatic` to `1.5.14`
  - `llfuse` to `1.3.8`
