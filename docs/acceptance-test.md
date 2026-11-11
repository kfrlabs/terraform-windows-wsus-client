# Acceptance test — live Windows host (issue #17)

Real-host validation of `terraform-windows-wsus-client` against a Windows
Server target over OpenSSH. Static checks (`fmt`, `validate`, `tflint`,
`terraform-docs`) are covered by CI; this document records the live
`plan` / `apply` / `reg query` / `destroy` behaviour that CI cannot cover.

## Environment

| Item | Value |
|---|---|
| Date | 2026-11-11 |
| Host | 172.18.122.203 (disposable test server, non-production) |
| OS | Microsoft Windows Server 2025 Standard, 10.0.26100 |
| PowerShell | 5.1.26100.33438 |
| Domain-joined | No (`PartOfDomain = False`) |
| Caller admin | Yes (`adminlocalecritel`, local Administrators) |
| OpenSSH | Server present, key auth (`id_rsa`), host key pinned via `known_hosts` |
| Terraform | v1.11.4 (linux_arm64) |
| Provider | `kfrlabs/windows` v0.3.1 (locked) |
| Module source | repo at merge commit for PR #33 (`a7fde96`) + `main.tf` ignore_changes fix (this branch) |

Provider connection used only environment variables (no secrets in files):
`WINDOWS_HOST`, `WINDOWS_USERNAME`, `WINDOWS_PRIVATE_KEY_PATH`.
Host-key verification left enabled (pinned `known_hosts` entry).

## Baseline (pre-test snapshot)

`reg export` saved on host as `C:\Windows\Temp\acc17-baseline.reg` before any
change. Live baseline:

```text
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    AUOptions    REG_DWORD    0x3
```

- The `WindowsUpdate` root key did not exist; only `AU\AUOptions = 3`.
- `wuauserv`: `Status = Stopped`, `StartType = Manual`.
- `gpupdate /force` after the full run left the restored baseline untouched
  (no GPO fight observed on this host).

## Scenario 0 — apply without import (fail-closed)

Scratch config (`server_url` only, `manage_wuauserv` default true), no import:

- `plan`: 5 to add (2 `terraform_data` guards, `UseWUServer`, `WUServer`,
  `windows_service.wuauserv[0]` create).
- `apply`: registry values created, then service Create failed closed:

```text
Error: Create windows_service failed
  service 'wuauserv' already exists
  Kind: already_exists
```

- Registry after: `WUServer` (REG_SZ) + `UseWUServer` (`0x1`) present,
  pre-existing `AUOptions = 0x3` untouched.
- `destroy`: 4 destroyed, registry back to baseline. Service never
  duplicated or damaged.

Conclusion: the documented import-first flow is enforced by the provider
(`already_exists`), not just by documentation.

## Scenario basic — import, apply, empty re-plan, destroy

`examples/basic` (`server_url` only):

1. `terraform import 'module.wsus.windows_service.wuauserv[0]' wuauserv`
   → `Import successful!`
2. `plan` → 4 to add + 1 in-place service update (`start_type`
   `Manual -> Automatic` only — no replacement, no value deletion).
3. `apply` → success. Registry:

```text
HKEY_LOCAL_MACHINE\...\WindowsUpdate
    WUServer    REG_SZ    http://wsus.example.lan:8530
HKEY_LOCAL_MACHINE\...\WindowsUpdate\AU
    AUOptions      REG_DWORD    0x3   (pre-existing, untouched)
    UseWUServer    REG_DWORD    0x1
```

Service: `DisplayName = Windows Update` intact, description intact,
`Status = Stopped` (observe-only, no disruption), `StartType = Automatic`.
4. Second `plan` → `No changes. Your infrastructure matches the
   configuration.` (no phantom diff).
5. `destroy` → fails closed as designed:

```text
Error: Instance cannot be destroyed
  (lifecycle.prevent_destroy on windows_service.wuauserv[0])
```

6. `terraform state rm 'module.wsus.windows_service.wuauserv[0]'` then
   `destroy` → 4 destroyed. Registry back to baseline
   (`AUOptions = 0x3` only). Service survives (`Stopped`, `Automatic`).

## Scenario scheduled

`examples/scheduled` (server_url + `enable_status_server` + `Scheduled` /
`Tuesday` / `2`), same import-first flow:

- `apply` → 8 added, 0 changed. Registry:

```text
WUServer          REG_SZ     http://wsus.example.lan:8530
WUStatusServer    REG_SZ     http://wsus.example.lan:8530
AU\AUOptions             REG_DWORD    0x4
AU\ScheduledInstallDay   REG_DWORD    0x3   (Tuesday)
AU\ScheduledInstallTime  REG_DWORD    0x2
AU\UseWUServer           REG_DWORD    0x1
```

Matches the README registry mapping exactly. Re-plan empty.
Teardown (`state rm` service + `destroy`): 8 destroyed.

## Scenario active-hours

`examples/active-hours` (scheduled + `active_hours_start = "8"`,
`active_hours_end = "18"`):

- `apply` → 11 added. Registry additionally:

```text
SetActiveHours      REG_DWORD    0x1   (WU root, not AU)
ActiveHoursStart    REG_DWORD    0x8   (WU root, not AU)
ActiveHoursEnd      REG_DWORD    0x12  (WU root, not AU)
```

Re-plan empty. Teardown: 11 destroyed.

## Value / Enabled matrix (`"false"` vs value vs `null`)

Scratch config: `Scheduled` trio + `manage_wuauserv = false` +
`detection_frequency_hours = "false"` +
`reboot_warning_timeout_minutes = "5"` +
`reschedule_wait_time_minutes = "false"`:

- `DetectionFrequency`: absent (`reg query` → not found) ;
  `DetectionFrequencyEnabled = 0x0` only.
- `RebootWarningTimeout = 0x5` + `RebootWarningTimeoutEnabled = 0x1`.
- `RescheduleWaitTime`: absent ;
  `RescheduleWaitTimeEnabled = 0x0` (cross-variable guard passes because
  `AUOptions = Scheduled`).
- `null` inputs (basic scenario): no pair resources planned, keys untouched.
- `manage_wuauserv = false`: no service instance planned.

Teardown: 11 destroyed, registry clean.

## Negative controls (live host)

- `enable_status_server = true` without `server_url` → plan fails with the
  cross-variable precondition naming both variables
  (`enable_status_server requires server_url ...`), plus the expected
  provider null-value diagnostic. No changes applied.
- (Static, dummy host, issues #9–#11): out-of-range values, single-sided
  Active Hours, and mixed `"false"`/numeric pairs are all rejected; valid
  matrices produce exactly 0 / 1 / 2 / 3 resources per pair semantics.

## Finding fixed during this acceptance (module change in this branch)

First basic `apply` failed on the service update:

```text
Error: ... Update ... Cannot validate argument on parameter 'Description'.
The argument is null or empty.
```

Cause: with only `ignore_changes = [binary_path]`, plan nulled the
imported `description`/`display_name`/`service_account`/`dependencies` and
the provider forwarded empty values to `Set-Service`. Fix (in `main.tf`,
required for this acceptance to pass): import-only `ignore_changes` now
covers `binary_path`, `display_name`, `description`, `service_account`,
`dependencies` — only `start_type` is managed, `status` stays observe-only.
Re-run: service plan = `start_type` only, apply succeeds, description and
display name preserved, re-plan empty.

## Restoration proof

After all scenarios + matrix + negative controls:

- `Set-ItemProperty ... AUOptions 3` re-applied (it was managed-and-destroyed
  by the scheduled/active-hours scenarios), `Set-Service wuauserv -StartupType
  Manual` reverted, then verified:

```text
HKEY_LOCAL_MACHINE\...\WindowsUpdate\AU
    AUOptions    REG_DWORD    0x3
Get-Service wuauserv → Status: Stopped, StartType: Manual
```

Identical to the pre-test snapshot. `gpupdate /force` does not alter it.
No test state files were committed (`*.tfstate`, `.terraform/`,
`*.plan` are git-ignored and were removed from `examples/`).

## Result

- No phantom diff on any re-plan (basic, scheduled, active-hours).
- No unexpected deletion: `destroy` removed exactly the managed values;
  pre-existing `AUOptions = 0x3` survived every cycle (restored once after
  scenarios that legitimately managed it).
- Registry keys match the README registry mapping (types REG_SZ/REG_DWORD, DWORD values).
- `wuauserv` import-only flow proven: create-without-import fails closed,
  import-then-plan proposes in-place `start_type` only, `destroy` fails
  closed via `prevent_destroy`, `state rm` escape hatch proven.
- `"false"` → `*Enabled = 0` only; value → value + `Enabled = 1`;
  `null` → untouched. Cross-variable errors are clear and name both variables.

## Scenario purge (opt-in, issue #65) — pending live-host execution

Not yet executed on a live host. Procedure for a future acceptance run
(provider `kfrlabs/windows` `>= 0.4.0`):

1. Baseline: record `WindowsUpdate` root and `AU` subkey values
   (`reg query` both keys) with purge disabled (defaults).
2. Create one parasite `REG_SZ` under each key out-of-band
   (e.g. `reg add ... /v PurgeProbeWU`, `reg add ...\AU /v PurgeProbeAU`).
3. Enable `purge_unknown_wu_values = true` and
   `purge_unknown_au_values = true`; `plan` should list the parasites in
   `wu_unknown_value_names` / `au_unknown_value_names`.
4. `apply`: parasites deleted, every managed value intact
   (`reg query` comparison against step 1 plus managed values).
5. `destroy` (purge resources only): registry keys themselves survive
   (`delete_key_on_destroy = false`); managed values removed as usual.
6. Remove parasites if still present and verify the baseline is restored.
