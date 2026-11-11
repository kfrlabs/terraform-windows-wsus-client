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

```hcl
# module "wsus_client" {
#   source                 = "kfrlabs/wsus-client/windows"
#   version                = "~> 1.0"
#   server_url             = "https://wsus.example.lan:8531"
#   enable_status_server   = true
# }
```
