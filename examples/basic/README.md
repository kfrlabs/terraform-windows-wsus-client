# Basic WSUS client example

Points the client at a WSUS server with `server_url` only. All other
settings stay unmanaged (null = unmanaged).

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
#   source     = "kfrlabs/wsus-client/windows"
#   version    = "~> 1.0"
#   server_url = "http://wsus.example.lan:8530"
# }
```
