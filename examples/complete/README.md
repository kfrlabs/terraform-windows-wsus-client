# Complete WSUS client example

Exercises every input family: WSUS + status + alternate download
servers, scheduled installs, booleans, all five value/`Enabled` pairs
(including a `"false"` sentinel and the `Scheduled`-gated reschedule
pair), reboot minutes, Active Hours, `wuauserv` management and opt-in
purge with preview outputs. Remaining inputs keep their defaults
(`null` = unmanaged).

## Usage

```sh
terraform init
terraform validate
terraform plan -var windows_host=WIN01.example.lan -var windows_username=Administrator
terraform apply -var windows_host=WIN01.example.lan -var windows_username=Administrator
```

The provider authenticates with an SSH private key
(`-var windows_private_key_path=$HOME/.ssh/id_rsa`, or the
`WINDOWS_PRIVATE_KEY_PATH` environment variable instead of `-var` flags).
Host-key verification stays enabled by default; point
`known_hosts_path` at your `known_hosts` file when the host key is pinned.
Password auth remains available as an alternative: set `password` on the
provider block (or `WINDOWS_PASSWORD`) instead of `private_key_path`.

This example sets `manage_wuauserv = true`, so the `wuauserv` service
resource exists and is import-only (see the root README "Importing
wuauserv" section): import it before the first apply.

```sh
terraform import 'module.wsus_client.windows_service.wuauserv[0]' wuauserv
```

Purge preview outputs (`wu_unknown_value_names`,
`au_unknown_value_names`) list unmanaged values before apply; enabling
purge on keys managed by Group Policy is not supported.

## Registry use

To consume the published module, use the snippet below instead of `source = "../.."`.

```hcl
module "wsus_client" {
  source                 = "kfrlabs/wsus-client/windows"
  version                = "~> 1.0"
  server_url             = "https://wsus.example.lan:8531"
  enable_status_server   = true
  status_server_url      = "https://status.example.lan:8531"
  update_service_url_alternate = "https://cdn.example.lan:8531"

  auto_update_option     = "Scheduled"
  scheduled_install_day  = "Tuesday"
  scheduled_install_hour = 2

  no_auto_update             = false
  auto_install_minor_updates = false
  disable_dual_scan          = true

  detection_frequency_hours       = "22"
  reboot_relaunch_timeout_minutes = "10"
  reboot_warning_timeout_minutes  = "false"
  reschedule_wait_time_minutes    = "5"
  target_group                    = "Servers"

  always_auto_reboot_at_scheduled_time_minutes = 30
  active_hours_start                           = "8"
  active_hours_end                             = "18"

  manage_wuauserv         = true
  purge_unknown_wu_values = true
  purge_unknown_au_values = true
}
```
