provider "windows" {
  host     = var.windows_host
  username = var.windows_username
  password = var.windows_password # prefer private_key_path in real use; env fallback supported
}

module "wsus" {
  source = "../.."

  server_url             = "http://wsus.example.lan:8530"
  enable_status_server   = true
  auto_update_option     = "Scheduled"
  scheduled_install_day  = "Tuesday"
  scheduled_install_hour = 2
}
