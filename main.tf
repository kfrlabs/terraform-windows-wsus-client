locals {
  # AUOptions names to registry DWORD values (exact case).
  au_options_map = {
    NotifyOnly    = 2
    AutoNotify    = 3
    Scheduled     = 4
    AutoInstall   = 5
    NotifyRestart = 7
  }

  # Install-day names to registry DWORD values (exact case).
  scheduled_day_map = {
    Everyday  = 0
    Sunday    = 1
    Monday    = 2
    Tuesday   = 3
    Wednesday = 4
    Thursday  = 5
    Friday    = 6
    Saturday  = 7
  }

  # Effective DWORD values. Each accepts a symbolic name or a numeric string
  # (e.g. "Scheduled" or "4"); null stays null (unmanaged).
  # tonumber() runs only on the numeric-string fallback branch, after null
  # has been excluded (ADR-0001). Input names are validated in variables.tf.
  au_options_effective = var.auto_update_option == null ? null : (
    contains(keys(local.au_options_map), var.auto_update_option)
    ? local.au_options_map[var.auto_update_option]
    : tonumber(var.auto_update_option)
  )

  scheduled_day_effective = var.scheduled_install_day == null ? null : (
    contains(keys(local.scheduled_day_map), var.scheduled_install_day)
    ? local.scheduled_day_map[var.scheduled_install_day]
    : tonumber(var.scheduled_install_day)
  )

  # No "false" meaning for this key (ADR-0001); plain number|null passthrough.
  scheduled_hour_effective = var.scheduled_install_hour

  # Registry key paths. The provider hive ("HKLM") is excluded from the
  # path: WUServer lives at the WU root, UseWUServer in the AU subkey.
  wu_path = "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate"
  au_path = "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU"

  # Derived helpers for the core resources reused below.
  # Exact lowercase "false" only (ADR-0001, case-sensitive).
  is_wus_url = var.server_url != null && var.server_url != "false"

  # Simple booleans. null stays null (unmanaged);
  # true/false map to DWORD "1"/"0". WU root keys vs AU subkey per table.
  # Single input/metadata tables: boolean_settings, pair_values and
  # pair_enabled are derived below with one `for` each, so the key list and
  # the null/"false"/value semantics live in exactly one place per table.
  boolean_inputs = {
    accept_trusted_publisher_certs       = var.accept_trusted_publisher_certs
    disable_windows_update_access        = var.disable_windows_update_access
    elevate_non_admins                   = var.elevate_non_admins
    auto_install_minor_updates           = var.auto_install_minor_updates
    no_auto_reboot_with_logged_on_users  = var.no_auto_reboot_with_logged_on_users
    no_auto_update                       = var.no_auto_update
    always_auto_reboot_at_scheduled_time = var.always_auto_reboot_at_scheduled_time
  }

  boolean_meta = {
    accept_trusted_publisher_certs       = { path = local.wu_path, name = "AcceptTrustedPublisherCerts" }
    disable_windows_update_access        = { path = local.wu_path, name = "DisableWindowsUpdateAccess" }
    elevate_non_admins                   = { path = local.wu_path, name = "ElevateNonAdmins" }
    auto_install_minor_updates           = { path = local.au_path, name = "AutoInstallMinorUpdates" }
    no_auto_reboot_with_logged_on_users  = { path = local.au_path, name = "NoAutoRebootWithLoggedOnUsers" }
    no_auto_update                       = { path = local.au_path, name = "NoAutoUpdate" }
    always_auto_reboot_at_scheduled_time = { path = local.au_path, name = "AlwaysAutoRebootAtScheduledTime" }
  }

  boolean_settings = { for k, raw in local.boolean_inputs : k => {
    path  = local.boolean_meta[k].path
    name  = local.boolean_meta[k].name
    value = raw == null ? null : (raw ? "1" : "0")
  } }

  # Value/Enabled pairs. null stays null (unmanaged,
  # no resources); "false" disables (value null, Enabled "0"); any other
  # valid value sets the value plus Enabled "1". tonumber() runs only after
  # null/"false" have been excluded (ADR-0001). Exact lowercase "false"
  # only (ADR-0001, case-sensitive).
  pair_inputs = {
    detection_frequency_hours       = var.detection_frequency_hours
    reboot_relaunch_timeout_minutes = var.reboot_relaunch_timeout_minutes
    reboot_warning_timeout_minutes  = var.reboot_warning_timeout_minutes
    reschedule_wait_time_minutes    = var.reschedule_wait_time_minutes
    target_group                    = var.target_group
  }

  # numeric = false for the free-string TargetGroup (no tonumber);
  # value and Enabled share the same key path per pair.
  pair_meta = {
    detection_frequency_hours       = { path = local.au_path, name = "DetectionFrequency", type = "REG_DWORD", enabled = "DetectionFrequencyEnabled", numeric = true }
    reboot_relaunch_timeout_minutes = { path = local.au_path, name = "RebootRelaunchTimeout", type = "REG_DWORD", enabled = "RebootRelaunchTimeoutEnabled", numeric = true }
    reboot_warning_timeout_minutes  = { path = local.au_path, name = "RebootWarningTimeout", type = "REG_DWORD", enabled = "RebootWarningTimeoutEnabled", numeric = true }
    reschedule_wait_time_minutes    = { path = local.au_path, name = "RescheduleWaitTime", type = "REG_DWORD", enabled = "RescheduleWaitTimeEnabled", numeric = true }
    target_group                    = { path = local.wu_path, name = "TargetGroup", type = "REG_SZ", enabled = "TargetGroupEnabled", numeric = false }
  }

  pair_values = { for k, raw in local.pair_inputs : k => {
    path  = local.pair_meta[k].path
    name  = local.pair_meta[k].name
    type  = local.pair_meta[k].type
    value = raw == null || raw == "false" ? null : (local.pair_meta[k].numeric ? tostring(tonumber(raw)) : raw)
  } }

  pair_enabled = { for k, raw in local.pair_inputs : k => {
    path  = local.pair_meta[k].path
    name  = local.pair_meta[k].enabled
    value = raw == null ? null : (raw == "false" ? "0" : "1")
  } }

  # Reboot minutes has no Enabled companion: null -> no resource
  # (unmanaged, no key); numeric 15-180 -> 1 DWORD resource.
  # Plain number (no "false" sentinel, like scheduled_install_hour).
  reboot_minutes_value = var.always_auto_reboot_at_scheduled_time_minutes == null ? null : tostring(var.always_auto_reboot_at_scheduled_time_minutes)

  # Active Hours joint state (2 inputs -> 3 resources): both null -> 0
  # resources; both "false" -> SetActiveHours "0" only; both numeric 0-23
  # -> SetActiveHours "1" + Start + End. Any mixed or single-set combination
  # is invalid (rejected by the active_hours_end variable validation).
  active_hours_both_false   = var.active_hours_start == "false" && var.active_hours_end == "false"
  active_hours_both_numeric = var.active_hours_start != null && var.active_hours_start != "false" && var.active_hours_end != null && var.active_hours_end != "false"
  active_hours_set_value    = local.active_hours_both_false ? "0" : "1"
  active_hours_start_value  = local.active_hours_both_numeric ? tostring(tonumber(var.active_hours_start)) : null
  active_hours_end_value    = local.active_hours_both_numeric ? tostring(tonumber(var.active_hours_end)) : null
}

# Core WSUS server resources (issue #6).
# server_url = null   -> unmanaged (count = 0, values left alone).
# server_url = "false" -> UseWUServer = "0", no WUServer value.
# server_url = <URL>   -> UseWUServer = "1" plus WUServer = <URL>.
# Removing a managed value (count flipping to 0) destroys it, i.e. the
# registry value is deleted (delete behaviour verified on a live host
# in #17).
resource "windows_registry_value" "use_wu_server" {
  count = var.server_url != null ? 1 : 0

  hive         = "HKLM"
  path         = local.au_path
  name         = "UseWUServer"
  type         = "REG_DWORD"
  value_string = local.is_wus_url ? "1" : "0"
}

resource "windows_registry_value" "wu_server" {
  count = local.is_wus_url ? 1 : 0

  hive         = "HKLM"
  path         = local.wu_path
  name         = "WUServer"
  type         = "REG_SZ"
  value_string = var.server_url
}

# enable_status_server = true  -> WUStatusServer follows server_url.
# enable_status_server = false -> value absent (count = 0, deleted if present).
# enable_status_server = null  -> unmanaged (count = 0).
# The true-without-server_url combination is rejected by the
# enable_status_server variable validation; no precondition here.
resource "windows_registry_value" "wu_status_server" {
  count = var.enable_status_server == true ? 1 : 0

  hive         = "HKLM"
  path         = local.wu_path
  name         = "WUStatusServer"
  type         = "REG_SZ"
  value_string = var.server_url
}

# Existing Windows Update service (issue #12). Import-only: only start_type is managed;
# all other attributes keep live values via ignore_changes below (binary_path is
# provider-required + ForceNew but host-dependent, so import keeps the live value).
resource "windows_service" "wuauserv" {
  count = var.manage_wuauserv ? 1 : 0

  name        = "wuauserv"
  binary_path = "C:\\Windows\\System32\\svchost.exe -k netsvcs -p"
  start_type  = "Automatic"

  lifecycle {
    prevent_destroy = true
    # Import-only: only start_type is managed. All other attributes keep their
    # live values after import; without this, plan nulls them and Update sends
    # empty values to Set-Service (fails closed, proven in #17 acceptance).
    ignore_changes = [
      binary_path,
      display_name,
      description,
      service_account,
      dependencies,
    ]
  }
}

# AUOptions scheduling resources (issue #7).
# AUOptions = 7 (NotifyRestart) requires Windows Server 2016 or later.
# null -> unmanaged (count = 0, values left alone).
# Removing a managed value (count flipping to 0) destroys it, i.e. the
# registry value is deleted (delete behaviour verified on a live host
# in #17). Scheduled mode additionally requires day +
# hour; that cross-variable rule is enforced by the auto_update_option
# variable validation.
resource "windows_registry_value" "au_options" {
  count = var.auto_update_option != null ? 1 : 0

  hive         = "HKLM"
  path         = local.au_path
  name         = "AUOptions"
  type         = "REG_DWORD"
  value_string = tostring(local.au_options_effective)
}

resource "windows_registry_value" "scheduled_install_day" {
  count = var.scheduled_install_day != null ? 1 : 0

  hive         = "HKLM"
  path         = local.au_path
  name         = "ScheduledInstallDay"
  type         = "REG_DWORD"
  value_string = tostring(local.scheduled_day_effective)
}

resource "windows_registry_value" "scheduled_install_hour" {
  count = var.scheduled_install_hour != null ? 1 : 0

  hive         = "HKLM"
  path         = local.au_path
  name         = "ScheduledInstallTime"
  type         = "REG_DWORD"
  value_string = tostring(local.scheduled_hour_effective)
}

# Cross-variable validations now live in variables.tf validation blocks
# (supported since Terraform 1.9; the module requires >= 1.11), so errors
# surface at input validation time and no guard resources pollute the state.
# The removed blocks below drop the legacy guards from existing states.
removed {
  from = terraform_data.cross_variable_validations

  lifecycle {
    destroy = false
  }
}

removed {
  from = terraform_data.active_hours_pair

  lifecycle {
    destroy = false
  }
}

# Simple booleans (issue #8). One resource per non-null entry; null entries
# are filtered out (unmanaged). Removing a managed value (var flipping back
# to null) destroys it, i.e. the registry value is deleted (verified on a
# live host in #17).
resource "windows_registry_value" "boolean_settings" {
  for_each = { for k, v in local.boolean_settings : k => v if v.value != null }

  hive         = "HKLM"
  path         = each.value.path
  name         = each.value.name
  type         = "REG_DWORD"
  value_string = each.value.value
}

# Value/Enabled pairs (issue #9). null -> no resources (unmanaged);
# "false" -> only the Enabled resource with "0"; value -> value resource
# plus Enabled "1". Removing a managed value (var flipping back to null)
# destroys it, i.e. the registry value is deleted (verified on a live host
# in #17).
resource "windows_registry_value" "pair_values" {
  for_each = { for k, v in local.pair_values : k => v if v.value != null }

  hive         = "HKLM"
  path         = each.value.path
  name         = each.value.name
  type         = each.value.type
  value_string = each.value.value
}

resource "windows_registry_value" "pair_enabled" {
  for_each = { for k, v in local.pair_enabled : k => v if v.value != null }

  hive         = "HKLM"
  path         = each.value.path
  name         = each.value.name
  type         = "REG_DWORD"
  value_string = each.value.value
}

# Reboot minutes (issue #10). null or "false" -> no resource (unmanaged,
# no key); numeric 15-180 -> 1 DWORD resource. Removing a managed value
# (var flipping back to null/"false") destroys it, i.e. the registry value
# is deleted (verified on a live host in #17).
resource "windows_registry_value" "always_auto_reboot_minutes" {
  count = local.reboot_minutes_value != null ? 1 : 0

  hive         = "HKLM"
  path         = local.au_path
  name         = "AlwaysAutoRebootAtScheduledTimeMinutes"
  type         = "REG_DWORD"
  value_string = local.reboot_minutes_value
}

# Active Hours (issue #10). Both null -> 0 resources; both "false" ->
# SetActiveHours "0" only; both numeric 0-23 -> all 3 resources. Mixed
# false/numeric or single-set combinations are rejected by the
# active_hours_end variable validation. Per Microsoft docs (configure
# active hours via the registry), SetActiveHours/ActiveHoursStart/ActiveHoursEnd
# live at the WindowsUpdate root key, not in the AU subkey. Removing a
# managed value destroys it, i.e. the registry value is deleted.
resource "windows_registry_value" "set_active_hours" {
  count = local.active_hours_both_false || local.active_hours_both_numeric ? 1 : 0

  hive         = "HKLM"
  path         = local.wu_path
  name         = "SetActiveHours"
  type         = "REG_DWORD"
  value_string = local.active_hours_set_value
}

resource "windows_registry_value" "active_hours_start" {
  count = local.active_hours_both_numeric ? 1 : 0

  hive         = "HKLM"
  path         = local.wu_path
  name         = "ActiveHoursStart"
  type         = "REG_DWORD"
  value_string = local.active_hours_start_value
}

resource "windows_registry_value" "active_hours_end" {
  count = local.active_hours_both_numeric ? 1 : 0

  hive         = "HKLM"
  path         = local.wu_path
  name         = "ActiveHoursEnd"
  type         = "REG_DWORD"
  value_string = local.active_hours_end_value
}
