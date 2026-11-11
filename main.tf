locals {
  # Puppet AUOptions names to registry DWORD values (exact case).
  au_options_map = {
    NotifyOnly    = 2
    AutoNotify    = 3
    Scheduled     = 4
    AutoInstall   = 5
    NotifyRestart = 7
  }

  # Puppet install-day names to registry DWORD values (exact case).
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

  # Effective DWORD values. Each accepts a Puppet name or a numeric string
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
  # path: WUServer lives at the WU root, UseWUServer in the AU subkey
  # (PLAN.md §2).
  wu_path = "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate"
  au_path = "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU"

  # Provisional helpers for the core resources (issue #6 reuses them).
  # Exact lowercase "false" only (ADR-0001, case-sensitive).
  is_wus_disabled = var.server_url == "false"
  is_wus_url      = var.server_url != null && var.server_url != "false"

  # Simple booleans (issue #8, PLAN.md §2). null stays null (unmanaged);
  # true/false map to DWORD "1"/"0". WU root keys vs AU subkey per table.
  boolean_settings = {
    accept_trusted_publisher_certs = {
      path  = local.wu_path
      name  = "AcceptTrustedPublisherCerts"
      value = var.accept_trusted_publisher_certs == null ? null : (var.accept_trusted_publisher_certs ? "1" : "0")
    }
    disable_windows_update_access = {
      path  = local.wu_path
      name  = "DisableWindowsUpdateAccess"
      value = var.disable_windows_update_access == null ? null : (var.disable_windows_update_access ? "1" : "0")
    }
    elevate_non_admins = {
      path  = local.wu_path
      name  = "ElevateNonAdmins"
      value = var.elevate_non_admins == null ? null : (var.elevate_non_admins ? "1" : "0")
    }
    auto_install_minor_updates = {
      path  = local.au_path
      name  = "AutoInstallMinorUpdates"
      value = var.auto_install_minor_updates == null ? null : (var.auto_install_minor_updates ? "1" : "0")
    }
    no_auto_reboot_with_logged_on_users = {
      path  = local.au_path
      name  = "NoAutoRebootWithLoggedOnUsers"
      value = var.no_auto_reboot_with_logged_on_users == null ? null : (var.no_auto_reboot_with_logged_on_users ? "1" : "0")
    }
    no_auto_update = {
      path  = local.au_path
      name  = "NoAutoUpdate"
      value = var.no_auto_update == null ? null : (var.no_auto_update ? "1" : "0")
    }
    always_auto_reboot_at_scheduled_time = {
      path  = local.au_path
      name  = "AlwaysAutoRebootAtScheduledTime"
      value = var.always_auto_reboot_at_scheduled_time == null ? null : (var.always_auto_reboot_at_scheduled_time ? "1" : "0")
    }
  }

  # Value/Enabled pairs (issue #9, PLAN.md §2). null stays null (unmanaged,
  # no resources); "false" disables (value null, Enabled "0"); any other
  # valid value sets the value plus Enabled "1". tonumber() runs only after
  # null/"false" have been excluded (ADR-0001). Exact lowercase "false"
  # only (ADR-0001, case-sensitive).
  pair_values = {
    detection_frequency_hours = {
      path  = local.au_path
      name  = "DetectionFrequency"
      type  = "REG_DWORD"
      value = var.detection_frequency_hours == null || var.detection_frequency_hours == "false" ? null : tostring(tonumber(var.detection_frequency_hours))
    }
    reboot_relaunch_timeout_minutes = {
      path  = local.au_path
      name  = "RebootRelaunchTimeout"
      type  = "REG_DWORD"
      value = var.reboot_relaunch_timeout_minutes == null || var.reboot_relaunch_timeout_minutes == "false" ? null : tostring(tonumber(var.reboot_relaunch_timeout_minutes))
    }
    reboot_warning_timeout_minutes = {
      path  = local.au_path
      name  = "RebootWarningTimeout"
      type  = "REG_DWORD"
      value = var.reboot_warning_timeout_minutes == null || var.reboot_warning_timeout_minutes == "false" ? null : tostring(tonumber(var.reboot_warning_timeout_minutes))
    }
    reschedule_wait_time_minutes = {
      path  = local.au_path
      name  = "RescheduleWaitTime"
      type  = "REG_DWORD"
      value = var.reschedule_wait_time_minutes == null || var.reschedule_wait_time_minutes == "false" ? null : tostring(tonumber(var.reschedule_wait_time_minutes))
    }
    target_group = {
      path  = local.wu_path
      name  = "TargetGroup"
      type  = "REG_SZ"
      value = var.target_group == null || var.target_group == "false" ? null : var.target_group
    }
  }

  pair_enabled = {
    detection_frequency_hours = {
      path  = local.au_path
      name  = "DetectionFrequencyEnabled"
      value = var.detection_frequency_hours == null ? null : (var.detection_frequency_hours == "false" ? "0" : "1")
    }
    reboot_relaunch_timeout_minutes = {
      path  = local.au_path
      name  = "RebootRelaunchTimeoutEnabled"
      value = var.reboot_relaunch_timeout_minutes == null ? null : (var.reboot_relaunch_timeout_minutes == "false" ? "0" : "1")
    }
    reboot_warning_timeout_minutes = {
      path  = local.au_path
      name  = "RebootWarningTimeoutEnabled"
      value = var.reboot_warning_timeout_minutes == null ? null : (var.reboot_warning_timeout_minutes == "false" ? "0" : "1")
    }
    reschedule_wait_time_minutes = {
      path  = local.au_path
      name  = "RescheduleWaitTimeEnabled"
      value = var.reschedule_wait_time_minutes == null ? null : (var.reschedule_wait_time_minutes == "false" ? "0" : "1")
    }
    target_group = {
      path  = local.wu_path
      name  = "TargetGroupEnabled"
      value = var.target_group == null ? null : (var.target_group == "false" ? "0" : "1")
    }
  }
}

# Core WSUS server resources (issue #6).
# server_url = null   -> unmanaged (count = 0, values left alone).
# server_url = "false" -> UseWUServer = "0", no WUServer value.
# server_url = <URL>   -> UseWUServer = "1" plus WUServer = <URL>.
# Removing a managed value (count flipping to 0) destroys it, i.e. the
# registry value is deleted. Actual delete behaviour on a live host is
# still to be verified in #17.
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
# The true-without-server_url combination is rejected later by the
# cross-variable precondition (issue #11); no precondition here.
resource "windows_registry_value" "wu_status_server" {
  count = var.enable_status_server == true ? 1 : 0

  hive         = "HKLM"
  path         = local.wu_path
  name         = "WUStatusServer"
  type         = "REG_SZ"
  value_string = var.server_url
}

# AUOptions scheduling resources (issue #7).
# AUOptions = 7 (NotifyRestart) requires Windows Server 2016 or later.
# null -> unmanaged (count = 0, values left alone).
# Removing a managed value (count flipping to 0) destroys it, i.e. the
# registry value is deleted. Actual delete behaviour on a live host is
# still to be verified in #17. Scheduled mode additionally requires day +
# hour; that cross-variable rule is enforced later (issue #11).
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

# NOTE: cross-variable lifecycle preconditions (enable_status_server
# requiring a server_url URL, Scheduled requiring day + hour) will be
# enforced here in issue #11. Placeholder only — no preconditions yet.

# Simple booleans (issue #8). One resource per non-null entry; null entries
# are filtered out (unmanaged). Removing a managed value (var flipping back
# to null) destroys it, i.e. the registry value is deleted. Actual delete
# behaviour on a live host is still to be verified in #17.
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
# destroys it, i.e. the registry value is deleted. Actual delete behaviour
# on a live host is still to be verified in #17.
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
