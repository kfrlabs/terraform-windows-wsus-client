# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

No changes yet beyond the `1.0.0` scope below.

## 1.0.0 - TBD (tracks #18)

First Registry release. Constraints: Terraform `>= 1.11`, provider
`kfrlabs/windows` `>= 0.4.0, < 0.5.0`.

### Added

- WSUS server management: `server_url` (`UseWUServer` + `WUServer`),
  `enable_status_server` with `status_server_url` override
  (`WUStatusServer`), `update_service_url_alternate`.
- `AUOptions` scheduling (`auto_update_option`, `scheduled_install_day`,
  `scheduled_install_hour`), 10 boolean settings, 5 value/`Enabled`
  pairs, reboot minutes, Active Hours.
- Import-only `wuauserv` service management (`manage_wuauserv`, opt-in).
- Opt-in purge of unmanaged values (`purge_unknown_wu_values`,
  `purge_unknown_au_values`); live-host acceptance recorded in
  `docs/acceptance-test.md`.
- Strict input validation: full-string URL pattern (bare scheme and
  whitespace rejected); `status_server_url` requires
  `enable_status_server = true` (which itself requires a `server_url`
  URL); `update_service_url_alternate` requires `server_url` to be a
  URL; schedule/pair consistency rules.
- Mocked `terraform test` suite, `basic`/`scheduled`/`active-hours`
  examples (HTTPS, SSH key auth), `SECURITY.md`, `CODEOWNERS`,
  Dependabot coverage for Terraform dependencies.

### Changed

- **Breaking:** `manage_wuauserv` now defaults to `false` (opt-in, #39).
  Migration: set `manage_wuauserv = true` and import the service to keep
  managing it; otherwise it is left unmanaged.
- **Breaking:** `always_auto_reboot_at_scheduled_time_minutes` is a
  nullable `number` (`15-180`); the `"false"` sentinel is rejected (#44).
  Migration: replace `"false"` with `null` (key left unmanaged).
- **Breaking:** `terraform_data` guard preconditions replaced by native
  variable validations (#42). Migration: none required — `removed`
  blocks drop the guards from existing states on next apply.
- **Breaking:** provider minimum raised to `>= 0.4.0, < 0.5.0` (#65).

### Fixed

- Active Hours values are written at the `WindowsUpdate` root, not `AU`.
- Validation gaps closed for `target_group` case variants, Active Hours
  ranges and schedule combinations.
- Documentation: Requirements section, `false`-semantics wording, stale
  comments, wuauserv mapping, purge import addresses.

### Security

- Examples and Usage snippet use `https://...:8531`; new Security
  considerations section and per-variable warnings for HTTP and
  posture-weakening options.
- Examples authenticate with SSH keys by default; test infrastructure
  details anonymized in the acceptance report.
