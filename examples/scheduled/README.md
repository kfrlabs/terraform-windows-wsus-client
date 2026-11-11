# Scheduled install example

Points the client at a WSUS server and schedules installs for Tuesday at
02:00 (`auto_update_option = "Scheduled"` with day and hour). The status
server follows `server_url` via `enable_status_server`.

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

The `wuauserv` service resource is import-only (see the root README
"Importing wuauserv" section): import it before the first apply.

```sh
terraform import 'module.wsus_client.windows_service.wuauserv[0]' wuauserv
```

## Registry use

```hcl
# module "wsus_client" {
#   source                 = "kfrlabs/wsus-client/windows"
#   version                = "~> 1.0"
#   server_url             = "https://wsus.example.lan:8531"
#   enable_status_server   = true
#   auto_update_option     = "Scheduled"
#   scheduled_install_day  = "Tuesday"
#   scheduled_install_hour = 2
# }
```
