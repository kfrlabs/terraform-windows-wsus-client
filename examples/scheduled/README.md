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

Credentials can also come from the provider's `WINDOWS_*` environment
variables instead of `-var` flags.

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
