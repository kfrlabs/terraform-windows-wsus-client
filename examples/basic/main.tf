provider "windows" {
  host             = var.windows_host
  username         = var.windows_username
  private_key_path = var.windows_private_key_path
}

module "wsus_client" {
  source = "../.."

  server_url = "https://wsus.example.lan:8531"
}
