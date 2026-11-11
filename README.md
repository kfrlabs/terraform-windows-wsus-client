# terraform-windows-wsus-client

Terraform module to manage WSUS (Windows Server Update Service) client settings on Windows via the `kfrlabs/windows` provider.

Every WSUS setting maps to a registry value under `HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate` (see mapping below), the wuauserv service excepted.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.11 |
| windows | >= 0.4.0, < 0.5.0 |

## Providers

| Name | Version |
|------|---------|
| windows | >= 0.4.0, < 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [windows_registry_key.au](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_key) | resource |
| [windows_registry_key.wu](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_key) | resource |
| [windows_registry_value.active_hours_end](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.active_hours_start](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.always_auto_reboot_minutes](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.au_options](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.boolean_settings](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.pair_enabled](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.pair_values](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.scheduled_install_day](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.scheduled_install_hour](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.set_active_hours](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.update_service_url_alternate](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.use_wu_server](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.wu_server](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.wu_status_server](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_service.wuauserv](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| accept\_trusted\_publisher\_certs | Accept trusted publisher certificates (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| active\_hours\_end | Active Hours end, 0-23 (ActiveHoursEnd). Set jointly with active\_hours\_start; null unmanaged, "false" disables (SetActiveHours=0 only). | `string` | `null` | no |
| active\_hours\_start | Active Hours start, 0-23 (ActiveHoursStart). Set jointly with active\_hours\_end; null unmanaged, "false" disables (SetActiveHours=0 only). | `string` | `null` | no |
| always\_auto\_reboot\_at\_scheduled\_time | Always auto-reboot at scheduled time (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| always\_auto\_reboot\_at\_scheduled\_time\_minutes | Minutes after scheduled install to force reboot, 15-180 (AlwaysAutoRebootAtScheduledTimeMinutes). null leaves the key unmanaged (no resource). | `number` | `null` | no |
| auto\_install\_minor\_updates | Auto-install minor updates (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| auto\_update\_option | AUOptions mode. Names or DWORD values as string: NotifyOnly/2, AutoNotify/3, Scheduled/4, AutoInstall/5, NotifyRestart/7 (2016+). null leaves it unmanaged. | `string` | `null` | no |
| detection\_frequency\_hours | Detection frequency in hours, 1-22 (DetectionFrequency). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |
| disable\_dual\_scan | Do not allow update deferral policies to cause scans against Windows Update (DisableDualScan DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| disable\_windows\_update\_access | Disable Windows Update access (DWORD 0/1). null unmanaged. Note: true blocks user-initiated update scans; clients depend solely on policy-driven updates. | `bool` | `null` | no |
| do\_not\_enforce\_tls\_cert\_pinning | Do not enforce TLS certificate pinning for Windows Update detection (DWORD 0/1). null unmanaged. WARNING: true weakens update-channel security; set only when required. | `bool` | `null` | no |
| elevate\_non\_admins | Allow non-admins to receive update notifications (DWORD 0/1). null unmanaged. Note: true widens who can interact with update notifications. | `bool` | `null` | no |
| enable\_status\_server | When true, WUStatusServer follows server\_url (or status\_server\_url when set). false and null leave it unmanaged (a previously managed value is deleted; use purge\_unknown\_wu\_values for unmanaged values). | `bool` | `null` | no |
| manage\_wuauserv | When true, manages the existing wuauserv service (start\_type Automatic). Requires prior 'terraform import' (see README). Flipping to false or destroy fails closed via prevent\_destroy; use 'terraform state rm' to stop managing. | `bool` | `false` | no |
| no\_auto\_reboot\_with\_logged\_on\_users | No auto-reboot with logged-on users (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| no\_auto\_update | Disable automatic updates (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| purge\_unknown\_au\_values | When true, purge unmanaged values under the WindowsUpdate\AU subkey via windows\_registry\_key (opt-in, live-host acceptance: docs/acceptance-test.md). The key itself is never deleted. Enabling purge on a key with no managed values under it deletes all values under that key. Do not enable on keys managed by Group Policy. | `bool` | `false` | no |
| purge\_unknown\_wu\_values | When true, purge unmanaged values under the WindowsUpdate root key via windows\_registry\_key (opt-in, live-host acceptance: docs/acceptance-test.md). The key itself is never deleted. Enabling purge on a key with no managed values under it deletes all values under that key. Do not enable on keys managed by Group Policy. | `bool` | `false` | no |
| reboot\_relaunch\_timeout\_minutes | Reboot relaunch timeout in minutes, 1-1440 (RebootRelaunchTimeout). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |
| reboot\_warning\_timeout\_minutes | Reboot warning timeout in minutes, 1-30 (RebootWarningTimeout). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |
| reschedule\_wait\_time\_minutes | Reschedule wait time in minutes, 1-60 (RescheduleWaitTime). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |
| scheduled\_install\_day | Scheduled install day. Names or DWORD values as string: Everyday/0 ... Saturday/7. null leaves it unmanaged. | `string` | `null` | no |
| scheduled\_install\_hour | Scheduled install hour, 0-23 (maps to ScheduledInstallTime). null leaves it unmanaged. | `number` | `null` | no |
| server\_url | WSUS server URL (http(s)://...). "false" disables UseWUServer. null leaves settings unmanaged. Prefer https (default port 8531): plain http allows update interception on the wire. | `string` | `null` | no |
| set\_proxy\_behavior\_for\_update\_detection | Proxy behavior for update detection (DWORD): false uses the system proxy only (0), true allows user proxy as fallback (1). null unmanaged. WARNING: true lets a user-controlled proxy intercept update traffic. | `bool` | `null` | no |
| status\_server\_url | Optional WUStatusServer override (http(s)://...). null follows server\_url. Only used when enable\_status\_server is true. Prefer https: plain http allows update interception on the wire. | `string` | `null` | no |
| target\_group | Target group name (TargetGroup). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |
| update\_service\_url\_alternate | Alternate download server (UpdateServiceUrlAlternate REG\_SZ at the WU root). null leaves it unmanaged. Requires server\_url to be a URL (downloads replace the intranet update service). Prefer https: plain http allows update interception on the wire. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| au\_managed\_value\_names | Value names managed under the WindowsUpdate\AU subkey (purge exclusion list). |
| au\_options\_effective | Effective AUOptions DWORD value (number) or null when unmanaged. |
| au\_unknown\_value\_names | Live unmanaged value names under the AU subkey (purge preview; empty unless AU purge is enabled). |
| managed\_registry\_values | Sorted list of managed registry values as "path\name" strings. |
| scheduled\_install\_day\_effective | Effective ScheduledInstallDay DWORD value (number) or null when unmanaged. |
| status\_server | Managed WUStatusServer URL (string) or null when unmanaged, disabled, or without a valid server\_url. |
| wu\_managed\_value\_names | Value names managed under the WindowsUpdate root key (purge exclusion list). |
| wu\_server | Managed WUServer URL (string) or null when unmanaged or disabled. |
| wu\_unknown\_value\_names | Live unmanaged value names under the WU root key (purge preview; empty unless WU purge is enabled). |
| wuauserv\_managed | Whether the wuauserv service is managed (input intent, known pre-apply). |
<!-- END_TF_DOCS -->

## Usage

```hcl
module "wsus_client" {
  source     = "kfrlabs/wsus-client/windows"
  version    = "~> 1.0"
  server_url = "https://wsus.example.lan:8531"
}
```

Worked examples live in [`examples/basic`](examples/basic) (server URL only),
[`examples/scheduled`](examples/scheduled) (scheduled installs + status server),
[`examples/active-hours`](examples/active-hours) (plus Active Hours) and
[`examples/complete`](examples/complete) (full interface: pairs, booleans,
alternate server, `wuauserv`, purge).
Note the examples use `source = "../.."` for local development; replace with
the Registry source above when consuming the published module.
See [CHANGELOG.md](CHANGELOG.md) for release notes and breaking changes.

## Registry mapping

Base: `hive = "HKLM"`. The provider `path` excludes the hive:
`SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate` (WU root) and
`...\WindowsUpdate\AU` (AU subkey).

`null` (default) leaves a setting unmanaged (no resource).
`"false"` (exact lowercase, case-sensitive per ADR-0001)
disables a setting. Any other value manages it. All `REG_DWORD` values are
written as decimal strings (e.g. `"4"`), as required by the provider.

| Setting | Registry key(s) | TF input | null / `"false"` / value effect |
|---|---|---|---|
| `server_url` | `AU\UseWUServer` DWORD, `WUServer` REG_SZ (WU root) | `server_url` (string) | `null` unmanaged; `"false"` → `UseWUServer = "0"` only; URL → `"1"` + `WUServer = url` |
| `enable_status_server` | `WUStatusServer` REG_SZ (WU root) | `enable_status_server` (bool) | `null`/`false` unmanaged (previously managed value deleted; use purge_unknown_wu_values for unmanaged values); `true` → `= status_server_url` if set, else `= server_url` (requires `server_url` URL) |
| `status_server_url` | `WUStatusServer` REG_SZ (WU root) | `status_server_url` (string) | `null` → follows `server_url`; URL → that value (only used when `enable_status_server = true`) |
| `update_service_url_alternate` | `UpdateServiceUrlAlternate` REG_SZ (WU root) | string | `null` unmanaged; URL → managed (alternate download server, requires `server_url` URL) |
| `auto_update_option` | `AU\AUOptions` DWORD | `auto_update_option` (string) | `NotifyOnly`/`2`, `AutoNotify`/`3`, `Scheduled`/`4`, `AutoInstall`/`5`, `NotifyRestart`/`7` (`7` = Server 2016+). `Scheduled` requires day + hour |
| `scheduled_install_day` | `AU\ScheduledInstallDay` DWORD | `scheduled_install_day` (string) | `Everyday`/`0` … `Saturday`/`7` |
| `scheduled_install_hour` | `AU\ScheduledInstallTime` DWORD | `scheduled_install_hour` (number) | `0-23`. No `"false"` meaning (plain `number`) |
| `accept_trusted_publisher_certs` | `AcceptTrustedPublisherCerts` DWORD (WU root) | bool | `null` unmanaged; `true`/`false` → `"1"`/`"0"` |
| `disable_windows_update_access` | `DisableWindowsUpdateAccess` DWORD (WU root) | bool | `null` unmanaged; `true`/`false` → `"1"`/`"0"` |
| `elevate_non_admins` | `ElevateNonAdmins` DWORD (WU root) | bool | `null` unmanaged; `true`/`false` → `"1"`/`"0"` |
| `auto_install_minor_updates` | `AU\AutoInstallMinorUpdates` DWORD | bool | `null` unmanaged; `true`/`false` → `"1"`/`"0"` |
| `no_auto_reboot_with_logged_on_users` | `AU\NoAutoRebootWithLoggedOnUsers` DWORD | bool | `null` unmanaged; `true`/`false` → `"1"`/`"0"` |
| `no_auto_update` | `AU\NoAutoUpdate` DWORD | bool | `null` unmanaged; `true`/`false` → `"1"`/`"0"` |
| `always_auto_reboot_at_scheduled_time` | `AU\AlwaysAutoRebootAtScheduledTime` DWORD | bool | `null` unmanaged; `true`/`false` → `"1"`/`"0"` |
| `disable_dual_scan` | `DisableDualScan` DWORD (WU root) | bool | `null` unmanaged; `true`/`false` → `"1"`/`"0"` (no Dual Scan against Windows Update) |
| `do_not_enforce_tls_cert_pinning` | `DoNotEnforceEnterpriseTLSCertPinningForUpdateDetection` DWORD (WU root) | bool | `null` unmanaged; `true`/`false` → `"1"`/`"0"` |
| `set_proxy_behavior_for_update_detection` | `SetProxyBehaviorForUpdateDetection` DWORD (WU root) | bool | `null` unmanaged; `false` → `"0"` (system proxy only); `true` → `"1"` (user proxy fallback) |
| `detection_frequency_hours` | `AU\DetectionFrequency` + `DetectionFrequencyEnabled` DWORD | string | `1-22` → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing |
| `reboot_relaunch_timeout_minutes` | `AU\RebootRelaunchTimeout` + `RebootRelaunchTimeoutEnabled` DWORD | string | `1-1440` → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing |
| `reboot_warning_timeout_minutes` | `AU\RebootWarningTimeout` + `RebootWarningTimeoutEnabled` DWORD | string | `1-30` → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing |
| `reschedule_wait_time_minutes` | `AU\RescheduleWaitTime` + `RescheduleWaitTimeEnabled` DWORD | string | `1-60` → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing. Requires `auto_update_option = "Scheduled"`/`"4"` |
| `target_group` | `TargetGroup` REG_SZ + `TargetGroupEnabled` DWORD (WU root) | string | name → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing |
| `always_auto_reboot_at_scheduled_time_minutes` | `AU\AlwaysAutoRebootAtScheduledTimeMinutes` DWORD | number | `15-180` → one DWORD resource; `null` → no resource (unmanaged) |
| `active_hours_start` / `active_hours_end` | `SetActiveHours` + `ActiveHoursStart` + `ActiveHoursEnd` DWORD (WU root) | string pair | Both `null` → nothing; both `"false"` → `SetActiveHours = "0"` only; both `0-23` → `"1"` + Start + End. Mixed states rejected |
| service `wuauserv` | `start_type = "Automatic"` (other attributes ignored via `ignore_changes`) | `manage_wuauserv` (bool, default `false`) | Opt-in, import-only (see below). `false` leaves the service unmanaged |

## Limitations

- **Group Policy conflict.** If a GPO manages the same `WindowsUpdate` keys (or the `wuauserv` startup type), Terraform and GPO will fight. Do not use this module for keys a GPO controls.
- **Opt-in key purge (live-host acceptance: `docs/acceptance-test.md`).** `purge_unknown_wu_values` / `purge_unknown_au_values` (default `false`, strictly unchanged default behaviour) purge unmanaged values under the WU root / AU subkey via `windows_registry_key` (provider `>= 0.4.0`). Keys are never deleted (`delete_key_on_destroy = false`). Enabling purge on a key with no managed values under it deletes all values under that key. Plan previews via `wu_unknown_value_names` / `au_unknown_value_names` outputs. Import when enabling on existing keys: `terraform import 'module.wsus_client.windows_registry_key.wu[0]' 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'` and `terraform import 'module.wsus_client.windows_registry_key.au[0]' 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'`. Do not enable purge on keys managed by Group Policy.
- **`AUOptions = 7` (`NotifyRestart`) requires Windows Server 2016 or later.**
- **`"false"` literal edge.** `target_group = "false"` means disabled (`TargetGroupEnabled = "0"`), so a group literally named `false` cannot be managed. Case variants (`"False"`, `"FALSE"`, ...) are rejected by validation. Same exact-lowercase rule applies to every `"false"` sentinel.

## Security considerations

- **Prefer HTTPS for WSUS URLs.** `server_url`, `status_server_url` and `update_service_url_alternate` accept plain `http://` for legacy servers, but HTTP allows interception and injection of fake updates on the wire (WSUS MITM). Use `https://<host>:8531` (all examples do). HTTP is accepted, never required.
- **Do not weaken the update channel unintentionally.**
  - `do_not_enforce_tls_cert_pinning = true` disables TLS certificate pinning for update detection.
  - `set_proxy_behavior_for_update_detection = true` allows fallback to a user-controlled proxy for update traffic.
  - `elevate_non_admins = true` widens who can interact with update notifications.
  - Prefer the `null` (unmanaged) defaults unless the setting is explicitly required.
- **Availability tradeoff.** `disable_windows_update_access = true` blocks user-initiated scans; clients then depend solely on policy-driven updates.

## Importing wuauserv

`windows_service.wuauserv` manages the pre-existing Windows Update service,
but only when `manage_wuauserv = true` (default `false`: opt-in, the service
is left unmanaged). The provider's Delete really deletes the service and
Create fails when the service already exists, so the resource is import-only:
run `terraform import` before the first `terraform apply`, otherwise apply
fails closed.

```sh
terraform import 'windows_service.wuauserv[0]' wuauserv
# When consumed as a child module named "wsus_client":
terraform import 'module.wsus_client.windows_service.wuauserv[0]' wuauserv
```

`manage_wuauserv = false` removes the resource from the plan, but
`prevent_destroy` makes destroy (or flipping the switch) fail closed so the
service is never deleted. To stop managing it, remove it from state instead:

```sh
terraform state rm 'windows_service.wuauserv[0]'
```

Note: if Group Policy controls the Windows Update service startup type,
Terraform and GPO will fight; prefer leaving the service unmanaged in that
case. Live host behaviour is verified in #17.

## Credits

Design inspired by the `puppetlabs/wsus_client` Puppet module.
