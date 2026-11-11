# terraform-windows-wsus-client

Terraform module to manage WSUS (Windows Server Update Service) client settings on Windows via the `kfrlabs/windows` provider.

Every WSUS setting maps to a registry value under `HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate` (see mapping below), the wuauserv service excepted.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_windows"></a> [windows](#provider\_windows) | 0.3.1 |

## Resources

| Name | Type |
|------|------|
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
| [windows_registry_value.use_wu_server](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.wu_server](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_registry_value.wu_status_server](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/registry_value) | resource |
| [windows_service.wuauserv](https://registry.terraform.io/providers/kfrlabs/windows/latest/docs/resources/service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accept_trusted_publisher_certs"></a> [accept\_trusted\_publisher\_certs](#input\_accept\_trusted\_publisher\_certs) | Accept trusted publisher certificates (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| <a name="input_active_hours_end"></a> [active\_hours\_end](#input\_active\_hours\_end) | Active Hours end, 0-23 (ActiveHoursEnd). Set jointly with active\_hours\_start; null unmanaged, "false" disables (SetActiveHours=0 only). | `string` | `null` | no |
| <a name="input_active_hours_start"></a> [active\_hours\_start](#input\_active\_hours\_start) | Active Hours start, 0-23 (ActiveHoursStart). Set jointly with active\_hours\_end; null unmanaged, "false" disables (SetActiveHours=0 only). | `string` | `null` | no |
| <a name="input_always_auto_reboot_at_scheduled_time"></a> [always\_auto\_reboot\_at\_scheduled\_time](#input\_always\_auto\_reboot\_at\_scheduled\_time) | Always auto-reboot at scheduled time (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| <a name="input_always_auto_reboot_at_scheduled_time_minutes"></a> [always\_auto\_reboot\_at\_scheduled\_time\_minutes](#input\_always\_auto\_reboot\_at\_scheduled\_time\_minutes) | Minutes after scheduled install to force reboot, 15-180 (AlwaysAutoRebootAtScheduledTimeMinutes). null unmanaged, "false" leaves the key unmanaged (no resource). | `string` | `null` | no |
| <a name="input_auto_install_minor_updates"></a> [auto\_install\_minor\_updates](#input\_auto\_install\_minor\_updates) | Auto-install minor updates (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| <a name="input_auto_update_option"></a> [auto\_update\_option](#input\_auto\_update\_option) | AUOptions mode. Names or DWORD values as string: NotifyOnly/2, AutoNotify/3, Scheduled/4, AutoInstall/5, NotifyRestart/7 (2016+). | `string` | `null` | no |
| <a name="input_detection_frequency_hours"></a> [detection\_frequency\_hours](#input\_detection\_frequency\_hours) | Detection frequency in hours, 1-22 (DetectionFrequency). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |
| <a name="input_disable_windows_update_access"></a> [disable\_windows\_update\_access](#input\_disable\_windows\_update\_access) | Disable Windows Update access (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| <a name="input_elevate_non_admins"></a> [elevate\_non\_admins](#input\_elevate\_non\_admins) | Allow non-admins to receive update notifications (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| <a name="input_enable_status_server"></a> [enable\_status\_server](#input\_enable\_status\_server) | When true, WUStatusServer follows server\_url. null leaves it unmanaged. | `bool` | `null` | no |
| <a name="input_manage_wuauserv"></a> [manage\_wuauserv](#input\_manage\_wuauserv) | When true, manages the existing wuauserv service (start\_type Automatic). Requires prior 'terraform import' (see README). Flipping to false or destroy fails closed via prevent\_destroy; use 'terraform state rm' to stop managing. | `bool` | `false` | no |
| <a name="input_no_auto_reboot_with_logged_on_users"></a> [no\_auto\_reboot\_with\_logged\_on\_users](#input\_no\_auto\_reboot\_with\_logged\_on\_users) | No auto-reboot with logged-on users (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| <a name="input_no_auto_update"></a> [no\_auto\_update](#input\_no\_auto\_update) | Disable automatic updates (DWORD 0/1). null unmanaged. | `bool` | `null` | no |
| <a name="input_reboot_relaunch_timeout_minutes"></a> [reboot\_relaunch\_timeout\_minutes](#input\_reboot\_relaunch\_timeout\_minutes) | Reboot relaunch timeout in minutes, 1-1440 (RebootRelaunchTimeout). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |
| <a name="input_reboot_warning_timeout_minutes"></a> [reboot\_warning\_timeout\_minutes](#input\_reboot\_warning\_timeout\_minutes) | Reboot warning timeout in minutes, 1-30 (RebootWarningTimeout). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |
| <a name="input_reschedule_wait_time_minutes"></a> [reschedule\_wait\_time\_minutes](#input\_reschedule\_wait\_time\_minutes) | Reschedule wait time in minutes, 1-60 (RescheduleWaitTime). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |
| <a name="input_scheduled_install_day"></a> [scheduled\_install\_day](#input\_scheduled\_install\_day) | Scheduled install day. Names or DWORD values as string: Everyday/0 ... Saturday/7. | `string` | `null` | no |
| <a name="input_scheduled_install_hour"></a> [scheduled\_install\_hour](#input\_scheduled\_install\_hour) | Scheduled install hour, 0-23 (maps to ScheduledInstallTime). | `number` | `null` | no |
| <a name="input_server_url"></a> [server\_url](#input\_server\_url) | WSUS server URL (http(s)://...). "false" disables UseWUServer. null leaves settings unmanaged. | `string` | `null` | no |
| <a name="input_target_group"></a> [target\_group](#input\_target\_group) | Target group name (TargetGroup). null unmanaged, "false" disables (Enabled=0 only). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_au_options_effective"></a> [au\_options\_effective](#output\_au\_options\_effective) | Effective AUOptions DWORD value (number) or null when unmanaged. |
| <a name="output_managed_registry_values"></a> [managed\_registry\_values](#output\_managed\_registry\_values) | Sorted list of managed registry values as "path\name" strings. |
| <a name="output_scheduled_install_day_effective"></a> [scheduled\_install\_day\_effective](#output\_scheduled\_install\_day\_effective) | Effective ScheduledInstallDay DWORD value (number) or null when unmanaged. |
| <a name="output_status_server"></a> [status\_server](#output\_status\_server) | Managed WUStatusServer URL (string) or null when unmanaged, disabled, or without a valid server\_url. |
| <a name="output_wu_server"></a> [wu\_server](#output\_wu\_server) | Managed WUServer URL (string) or null when unmanaged or disabled. |
| <a name="output_wuauserv_managed"></a> [wuauserv\_managed](#output\_wuauserv\_managed) | Whether the wuauserv service is managed (input intent, known pre-apply). |
<!-- END_TF_DOCS -->

## Usage

```hcl
module "wsus" {
  source     = "kfrlabs/wsus-client/windows"
  version    = "~> 1.0"
  server_url = "http://wsus.example.lan:8530"
}
```

Worked examples live in [`examples/basic`](examples/basic) (server URL only),
[`examples/scheduled`](examples/scheduled) (scheduled installs + status server)
and [`examples/active-hours`](examples/active-hours) (plus Active Hours).
Note the examples use `source = "../.."` for local development; replace with
the Registry source above when consuming the published module.

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
| `enable_status_server` | `WUStatusServer` REG_SZ (WU root) | `enable_status_server` (bool) | `null` unmanaged; `false` absent; `true` → `= server_url` (requires `server_url` URL) |
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
| `detection_frequency_hours` | `AU\DetectionFrequency` + `DetectionFrequencyEnabled` DWORD | string | `1-22` → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing |
| `reboot_relaunch_timeout_minutes` | `AU\RebootRelaunchTimeout` + `RebootRelaunchTimeoutEnabled` DWORD | string | `1-1440` → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing |
| `reboot_warning_timeout_minutes` | `AU\RebootWarningTimeout` + `RebootWarningTimeoutEnabled` DWORD | string | `1-30` → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing |
| `reschedule_wait_time_minutes` | `AU\RescheduleWaitTime` + `RescheduleWaitTimeEnabled` DWORD | string | `1-60` → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing. Requires `auto_update_option = "Scheduled"`/`"4"` |
| `target_group` | `TargetGroup` REG_SZ + `TargetGroupEnabled` DWORD (WU root) | string | name → value + `Enabled = "1"`; `"false"` → `Enabled = "0"` only; `null` nothing |
| `always_auto_reboot_at_scheduled_time_minutes` | `AU\AlwaysAutoRebootAtScheduledTimeMinutes` DWORD | string | `15-180` → one DWORD resource; `null`/`"false"` → no resource (unmanaged equivalent) |
| `active_hours_start` / `active_hours_end` | `SetActiveHours` + `ActiveHoursStart` + `ActiveHoursEnd` DWORD (WU root) | string pair | Both `null` → nothing; both `"false"` → `SetActiveHours = "0"` only; both `0-23` → `"1"` + Start + End. Mixed states rejected |
| service `wuauserv` | `enable => true` | `manage_wuauserv` (bool, default `false`) | Opt-in, import-only (see below). `false` leaves the service unmanaged |

## Limitations

- **Group Policy conflict.** If a GPO manages the same `WindowsUpdate` keys (or the `wuauserv` startup type), Terraform and GPO will fight. Do not use this module for keys a GPO controls.
- **No key purge.** There is no registry-key purge behaviour: the `kfrlabs/windows` provider offers `windows_registry_value` only (keys are created implicitly). Stale values must be cleaned up manually (e.g. `Remove-ItemProperty`).
- **`AUOptions = 7` (`NotifyRestart`) requires Windows Server 2016 or later.**
- **`"false"` literal edge.** `target_group = "false"` means disabled (`TargetGroupEnabled = "0"`), so a group literally named `false` cannot be managed. Case variants (`"False"`, `"FALSE"`, ...) are rejected by validation. Same exact-lowercase rule applies to every `"false"` sentinel.

## Importing wuauserv

`windows_service.wuauserv` manages the pre-existing Windows Update service,
but only when `manage_wuauserv = true` (default `false`: opt-in, the service
is left unmanaged). The provider's Delete really deletes the service and
Create fails when the service already exists, so the resource is import-only:
run `terraform import` before the first `terraform apply`, otherwise apply
fails closed.

```sh
terraform import 'windows_service.wuauserv[0]' wuauserv
# When consumed as a child module named "wsus":
terraform import 'module.wsus.windows_service.wuauserv[0]' wuauserv
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
