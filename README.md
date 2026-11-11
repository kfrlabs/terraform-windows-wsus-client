# terraform-windows-wsus-client
Terraform module to manage WSUS client settings on Windows via kfrlabs/windows provider (port of puppetlabs/wsus_client)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Importing wuauserv

`windows_service.wuauserv` manages the pre-existing Windows Update service.
The provider's Delete really deletes the service and Create fails when the
service already exists, so the resource is import-only: run `terraform import`
before the first `terraform apply`, otherwise apply fails closed.

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
