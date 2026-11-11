provider "windows" {
  host             = var.windows_host
  username         = var.windows_username
  private_key_path = var.windows_private_key_path
}

module "wsus_client" {
  source = "../.."

  server_url                   = "https://wsus.example.lan:8531"
  enable_status_server         = true
  status_server_url            = "https://status.example.lan:8531"
  update_service_url_alternate = "https://cdn.example.lan:8531"

  auto_update_option     = "Scheduled"
  scheduled_install_day  = "Tuesday"
  scheduled_install_hour = 2

  no_auto_update             = false
  auto_install_minor_updates = false
  disable_dual_scan          = true

  detection_frequency_hours       = "22"
  reboot_relaunch_timeout_minutes = "10"
  reboot_warning_timeout_minutes  = "false"
  reschedule_wait_time_minutes    = "5"
  target_group                    = "Servers"

  always_auto_reboot_at_scheduled_time_minutes = 30
  active_hours_start                           = "8"
  active_hours_end                             = "18"

  manage_wuauserv         = true
  purge_unknown_wu_values = true
  purge_unknown_au_values = true
}
