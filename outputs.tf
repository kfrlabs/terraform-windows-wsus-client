# Outputs (issue #13). Pure projections of managed state; validation lives in
# variables.tf. No preconditions here.
output "au_options_effective" {
  description = "Effective AUOptions DWORD value (number) or null when unmanaged."
  value       = local.au_options_effective
}

output "wu_server" {
  description = "Managed WUServer URL (string) or null when unmanaged or disabled."
  value       = local.is_wus_url ? var.server_url : null
}

output "status_server" {
  description = "Managed WUStatusServer URL (string) or null when unmanaged, disabled, or without a valid server_url."
  value       = var.enable_status_server == true ? local.status_server_effective : null
}

output "scheduled_install_day_effective" {
  description = "Effective ScheduledInstallDay DWORD value (number) or null when unmanaged."
  value       = local.scheduled_day_effective
}

output "managed_registry_values" {
  description = "Sorted list of managed registry values as \"path\\name\" strings."
  value = sort(concat(
    [for r in windows_registry_value.use_wu_server : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.wu_server : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.wu_status_server : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.update_service_url_alternate : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.au_options : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.scheduled_install_day : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.scheduled_install_hour : "${r.path}\\${r.name}"],
    [for k, r in windows_registry_value.boolean_settings : "${r.path}\\${r.name}"],
    [for k, r in windows_registry_value.pair_values : "${r.path}\\${r.name}"],
    [for k, r in windows_registry_value.pair_enabled : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.always_auto_reboot_minutes : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.set_active_hours : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.active_hours_start : "${r.path}\\${r.name}"],
    [for r in windows_registry_value.active_hours_end : "${r.path}\\${r.name}"],
  ))
}

output "wuauserv_managed" {
  description = "Whether the wuauserv service is managed (input intent, known pre-apply)."
  value       = var.manage_wuauserv
}

output "wu_managed_value_names" {
  description = "Value names managed under the WindowsUpdate root key (purge exclusion list)."
  value       = local.wu_managed_value_names
}

output "au_managed_value_names" {
  description = "Value names managed under the WindowsUpdate\\AU subkey (purge exclusion list)."
  value       = local.au_managed_value_names
}

output "wu_unknown_value_names" {
  description = "Live unmanaged value names under the WU root key (purge preview; empty unless WU purge is enabled)."
  value       = try(windows_registry_key.wu[0].unknown_value_names, [])
}

output "au_unknown_value_names" {
  description = "Live unmanaged value names under the AU subkey (purge preview; empty unless AU purge is enabled)."
  value       = try(windows_registry_key.au[0].unknown_value_names, [])
}
