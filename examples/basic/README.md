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

The provider authenticates with an SSH private key
(`-var windows_private_key_path=$HOME/.ssh/id_rsa`, or the
`WINDOWS_PRIVATE_KEY_PATH` environment variable instead of `-var` flags).
Host-key verification stays enabled by default; point
`known_hosts_path` at your `known_hosts` file when the host key is pinned.
Password auth remains available as an alternative: set `password` on the
provider block (or `WINDOWS_PASSWORD`) instead of `private_key_path`.

The `wuauserv` service resource is opt-in (`manage_wuauserv = false`
by default, so the import below only applies when you set
`manage_wuauserv = true`) and import-only (see the root README
"Importing wuauserv" section): import it before the first apply.

```sh
terraform import 'module.wsus_client.windows_service.wuauserv[0]' wuauserv
```

## Registry use

To consume the published module, use the snippet below instead of `source = "../.."`.

```hcl
module "wsus_client" {
  source     = "kfrlabs/wsus-client/windows"
  version    = "~> 1.0"
  server_url = "https://wsus.example.lan:8531"
}
```
