provider "windows" {
  host     = var.windows_host
  username = var.windows_username
  password = var.windows_password # prefer private_key_path in real use; env fallback supported
}

module "wsus_client" {
  source = "../.."

  server_url             = "https://wsus.example.lan:8531"
  enable_status_server   = true
  auto_update_option     = "Scheduled"
  scheduled_install_day  = "Tuesday"
  scheduled_install_hour = 2
  active_hours_start     = "8"
  active_hours_end       = "18"
}
