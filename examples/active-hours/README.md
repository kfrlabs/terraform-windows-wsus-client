# Active Hours example

Extends the scheduled install (Tuesday 02:00) with Active Hours from 08:00
to 18:00, so Windows avoids disruptive reboots during the workday. The
start/end pair must always be set jointly.

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
terraform import 'module.wsus.windows_service.wuauserv[0]' wuauserv
```

## Registry use

```hcl
# module "wsus" {
#   source                 = "kfrlabs/wsus-client/windows"
#   version                = "~> 1.0"
#   server_url             = "http://wsus.example.lan:8530"
#   enable_status_server   = true
#   auto_update_option     = "Scheduled"
#   scheduled_install_day  = "Tuesday"
#   scheduled_install_hour = 2
#   active_hours_start     = "8"
#   active_hours_end       = "18"
# }
```
