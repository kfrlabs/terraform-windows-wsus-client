provider "windows" {
  host     = var.windows_host
  username = var.windows_username
  password = var.windows_password # prefer private_key_path in real use; env fallback supported
}

module "wsus_client" {
  source = "../.."

  server_url = "http://wsus.example.lan:8530"
}
