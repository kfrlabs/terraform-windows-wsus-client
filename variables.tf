variable "server_url" {
  description = "WSUS server URL (http(s)://...). \"false\" disables UseWUServer. null leaves settings unmanaged."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.server_url == null || var.server_url == "false" || can(regex("^https?://([[][^]\\s/]+[]]|[^\\]\\s/:[]+)(:[0-9]{1,5})?(/\\S*)?$", var.server_url))
    error_message = "server_url must be null, \"false\", or a valid http(s) URL (scheme, host, optional port and path, no spaces)."
  }
}

variable "enable_status_server" {
  description = "When true, WUStatusServer follows server_url. false and null leave it unmanaged (a previously managed value is deleted; use purge_unknown_wu_values for unmanaged values)."
  type        = bool
  nullable    = true
  default     = null

  validation {
    condition     = var.enable_status_server != true || (var.server_url != null && var.server_url != "false" && can(regex("^https?://([[][^]\\s/]+[]]|[^\\]\\s/:[]+)(:[0-9]{1,5})?(/\\S*)?$", var.server_url)))
    error_message = "enable_status_server requires server_url to be a valid http(s) URL (server_url must not be null or \"false\" when enable_status_server is true)."
  }
}

variable "status_server_url" {
  description = "Optional WUStatusServer override (http(s)://...). null follows server_url. Only used when enable_status_server is true."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.status_server_url == null || can(regex("^https?://([[][^]\\s/]+[]]|[^\\]\\s/:[]+)(:[0-9]{1,5})?(/\\S*)?$", var.status_server_url))
    error_message = "status_server_url must be null or a valid http(s) URL (scheme, host, optional port and path, no spaces)."
  }

  validation {
    condition     = var.status_server_url == null || var.enable_status_server == true
    error_message = "status_server_url has no effect unless enable_status_server is true."
  }
}

variable "update_service_url_alternate" {
  description = "Alternate download server (UpdateServiceUrlAlternate REG_SZ at the WU root). null leaves it unmanaged. Requires server_url to be a URL (downloads replace the intranet update service)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.update_service_url_alternate == null || can(regex("^https?://([[][^]\\s/]+[]]|[^\\]\\s/:[]+)(:[0-9]{1,5})?(/\\S*)?$", var.update_service_url_alternate))
    error_message = "update_service_url_alternate must be null or a valid http(s) URL (scheme, host, optional port and path, no spaces)."
  }

  validation {
    condition     = var.update_service_url_alternate == null || (var.server_url != null && var.server_url != "false" && can(regex("^https?://([[][^]\\s/]+[]]|[^\\]\\s/:[]+)(:[0-9]{1,5})?(/\\S*)?$", var.server_url)))
    error_message = "update_service_url_alternate has no effect unless server_url is a URL (the alternate replaces the intranet update service)."
  }
}

variable "auto_update_option" {
  description = "AUOptions mode. Names or DWORD values as string: NotifyOnly/2, AutoNotify/3, Scheduled/4, AutoInstall/5, NotifyRestart/7 (2016+)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.auto_update_option == null ? true : contains(["NotifyOnly", "AutoNotify", "Scheduled", "AutoInstall", "NotifyRestart", "2", "3", "4", "5", "7"], var.auto_update_option)
    error_message = "auto_update_option must be one of: NotifyOnly, AutoNotify, Scheduled, AutoInstall, NotifyRestart, 2, 3, 4, 5, 7."
  }

  validation {
    condition     = !(var.auto_update_option == "Scheduled" || var.auto_update_option == "4") || (var.scheduled_install_day != null && var.scheduled_install_hour != null)
    error_message = "auto_update_option \"Scheduled\"/\"4\" requires both scheduled_install_day and scheduled_install_hour to be set."
  }

  validation {
    condition     = (var.scheduled_install_day == null && var.scheduled_install_hour == null) || var.auto_update_option == "Scheduled" || var.auto_update_option == "4"
    error_message = "scheduled_install_day/scheduled_install_hour have no effect unless auto_update_option is \"Scheduled\"/\"4\"."
  }
}

variable "scheduled_install_day" {
  description = "Scheduled install day. Names or DWORD values as string: Everyday/0 ... Saturday/7."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.scheduled_install_day == null ? true : contains(["Everyday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "0", "1", "2", "3", "4", "5", "6", "7"], var.scheduled_install_day)
    error_message = "scheduled_install_day must be one of: Everyday, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, 0-7."
  }
}

variable "scheduled_install_hour" {
  description = "Scheduled install hour, 0-23 (maps to ScheduledInstallTime)."
  type        = number
  nullable    = true
  default     = null

  validation {
    condition     = var.scheduled_install_hour == null ? true : (var.scheduled_install_hour >= 0 && var.scheduled_install_hour <= 23 && floor(var.scheduled_install_hour) == var.scheduled_install_hour)
    error_message = "scheduled_install_hour must be an integer between 0 and 23."
  }
}

variable "accept_trusted_publisher_certs" {
  description = "Accept trusted publisher certificates (DWORD 0/1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "auto_install_minor_updates" {
  description = "Auto-install minor updates (DWORD 0/1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "disable_windows_update_access" {
  description = "Disable Windows Update access (DWORD 0/1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "elevate_non_admins" {
  description = "Allow non-admins to receive update notifications (DWORD 0/1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "no_auto_reboot_with_logged_on_users" {
  description = "No auto-reboot with logged-on users (DWORD 0/1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "no_auto_update" {
  description = "Disable automatic updates (DWORD 0/1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "always_auto_reboot_at_scheduled_time" {
  description = "Always auto-reboot at scheduled time (DWORD 0/1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "disable_dual_scan" {
  description = "Do not allow update deferral policies to cause scans against Windows Update (DisableDualScan DWORD 0/1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "do_not_enforce_tls_cert_pinning" {
  description = "Do not enforce TLS certificate pinning for Windows Update detection (DWORD 0/1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "set_proxy_behavior_for_update_detection" {
  description = "Proxy behavior for update detection (DWORD): false uses the system proxy only (0), true allows user proxy as fallback (1). null unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "detection_frequency_hours" {
  description = "Detection frequency in hours, 1-22 (DetectionFrequency). null unmanaged, \"false\" disables (Enabled=0 only)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.detection_frequency_hours == null ? true : var.detection_frequency_hours == "false" ? true : (can(tonumber(var.detection_frequency_hours)) ? (tonumber(var.detection_frequency_hours) >= 1 && tonumber(var.detection_frequency_hours) <= 22 && floor(tonumber(var.detection_frequency_hours)) == tonumber(var.detection_frequency_hours)) : false)
    error_message = "detection_frequency_hours must be null, \"false\", or an integer string between 1 and 22."
  }
}

variable "reboot_relaunch_timeout_minutes" {
  description = "Reboot relaunch timeout in minutes, 1-1440 (RebootRelaunchTimeout). null unmanaged, \"false\" disables (Enabled=0 only)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.reboot_relaunch_timeout_minutes == null ? true : var.reboot_relaunch_timeout_minutes == "false" ? true : (can(tonumber(var.reboot_relaunch_timeout_minutes)) ? (tonumber(var.reboot_relaunch_timeout_minutes) >= 1 && tonumber(var.reboot_relaunch_timeout_minutes) <= 1440 && floor(tonumber(var.reboot_relaunch_timeout_minutes)) == tonumber(var.reboot_relaunch_timeout_minutes)) : false)
    error_message = "reboot_relaunch_timeout_minutes must be null, \"false\", or an integer string between 1 and 1440."
  }
}

variable "reboot_warning_timeout_minutes" {
  description = "Reboot warning timeout in minutes, 1-30 (RebootWarningTimeout). null unmanaged, \"false\" disables (Enabled=0 only)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.reboot_warning_timeout_minutes == null ? true : var.reboot_warning_timeout_minutes == "false" ? true : (can(tonumber(var.reboot_warning_timeout_minutes)) ? (tonumber(var.reboot_warning_timeout_minutes) >= 1 && tonumber(var.reboot_warning_timeout_minutes) <= 30 && floor(tonumber(var.reboot_warning_timeout_minutes)) == tonumber(var.reboot_warning_timeout_minutes)) : false)
    error_message = "reboot_warning_timeout_minutes must be null, \"false\", or an integer string between 1 and 30."
  }
}

variable "reschedule_wait_time_minutes" {
  description = "Reschedule wait time in minutes, 1-60 (RescheduleWaitTime). null unmanaged, \"false\" disables (Enabled=0 only)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.reschedule_wait_time_minutes == null ? true : var.reschedule_wait_time_minutes == "false" ? true : (can(tonumber(var.reschedule_wait_time_minutes)) ? (tonumber(var.reschedule_wait_time_minutes) >= 1 && tonumber(var.reschedule_wait_time_minutes) <= 60 && floor(tonumber(var.reschedule_wait_time_minutes)) == tonumber(var.reschedule_wait_time_minutes)) : false)
    error_message = "reschedule_wait_time_minutes must be null, \"false\", or an integer string between 1 and 60."
  }

  validation {
    condition     = var.reschedule_wait_time_minutes == null || var.auto_update_option == "Scheduled" || var.auto_update_option == "4"
    error_message = "reschedule_wait_time_minutes (including \"false\") requires auto_update_option to be \"Scheduled\"/\"4\"."
  }
}

variable "target_group" {
  description = "Target group name (TargetGroup). null unmanaged, \"false\" disables (Enabled=0 only)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.target_group == null ? true : var.target_group == "false" ? true : (trimspace(var.target_group) != "" && lower(var.target_group) != "false")
    error_message = "target_group must be null, \"false\" (exact lowercase), or a non-empty group name; case variants of \"false\" (e.g. \"False\", \"FALSE\") are rejected."
  }
}

# Reboot minutes (no "false" sentinel: the key has no Enabled companion,
# so "false" was equivalent to null; plain number like scheduled_install_hour).
variable "always_auto_reboot_at_scheduled_time_minutes" {
  description = "Minutes after scheduled install to force reboot, 15-180 (AlwaysAutoRebootAtScheduledTimeMinutes). null leaves the key unmanaged (no resource)."
  type        = number
  nullable    = true
  default     = null

  validation {
    condition     = var.always_auto_reboot_at_scheduled_time_minutes == null ? true : (var.always_auto_reboot_at_scheduled_time_minutes >= 15 && var.always_auto_reboot_at_scheduled_time_minutes <= 180 && floor(var.always_auto_reboot_at_scheduled_time_minutes) == var.always_auto_reboot_at_scheduled_time_minutes)
    error_message = "always_auto_reboot_at_scheduled_time_minutes must be null or an integer between 15 and 180."
  }
}

variable "active_hours_start" {
  description = "Active Hours start, 0-23 (ActiveHoursStart). Set jointly with active_hours_end; null unmanaged, \"false\" disables (SetActiveHours=0 only)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.active_hours_start == null ? true : var.active_hours_start == "false" ? true : (can(tonumber(var.active_hours_start)) ? (tonumber(var.active_hours_start) >= 0 && tonumber(var.active_hours_start) <= 23 && floor(tonumber(var.active_hours_start)) == tonumber(var.active_hours_start)) : false)
    error_message = "active_hours_start must be null, \"false\", or an integer string between 0 and 23."
  }
}

variable "active_hours_end" {
  description = "Active Hours end, 0-23 (ActiveHoursEnd). Set jointly with active_hours_start; null unmanaged, \"false\" disables (SetActiveHours=0 only)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.active_hours_end == null ? true : var.active_hours_end == "false" ? true : (can(tonumber(var.active_hours_end)) ? (tonumber(var.active_hours_end) >= 0 && tonumber(var.active_hours_end) <= 23 && floor(tonumber(var.active_hours_end)) == tonumber(var.active_hours_end)) : false)
    error_message = "active_hours_end must be null, \"false\", or an integer string between 0 and 23."
  }

  validation {
    condition     = (var.active_hours_start == null && var.active_hours_end == null) || (var.active_hours_start == "false" && var.active_hours_end == "false") || (var.active_hours_start != null && var.active_hours_start != "false" && var.active_hours_end != null && var.active_hours_end != "false")
    error_message = "active_hours_start and active_hours_end must both be null, both be \"false\", or both be integer strings between 0 and 23."
  }

  validation {
    condition = (
      var.active_hours_start == null || var.active_hours_start == "false" || var.active_hours_end == null || var.active_hours_end == "false"
      ? true
      : !(can(tonumber(var.active_hours_start)) && can(tonumber(var.active_hours_end)))
      ? true
      : ((tonumber(var.active_hours_end) - tonumber(var.active_hours_start) + 24) % 24) >= 1 && ((tonumber(var.active_hours_end) - tonumber(var.active_hours_start) + 24) % 24) <= 18
    )
    error_message = "active_hours range must be between 1 and 18 hours (start must differ from end; range wraps modulo 24)."
  }
}

# Non-nullable explicit switches (issue #65): no null=unmanaged meaning.
# No validation blocks needed (bool type enforces).
variable "purge_unknown_wu_values" {
  description = "When true, purge unmanaged values under the WindowsUpdate root key via windows_registry_key (opt-in, experimental: live-host purge acceptance pending, see docs/acceptance-test.md). The key itself is never deleted. Enabling purge on a key with no managed values under it deletes all values under that key. Do not enable on keys managed by Group Policy."
  type        = bool
  nullable    = false
  default     = false
}

variable "purge_unknown_au_values" {
  description = "When true, purge unmanaged values under the WindowsUpdate\\AU subkey via windows_registry_key (opt-in, experimental: live-host purge acceptance pending, see docs/acceptance-test.md). The key itself is never deleted. Enabling purge on a key with no managed values under it deletes all values under that key. Do not enable on keys managed by Group Policy."
  type        = bool
  nullable    = false
  default     = false
}

# Non-nullable explicit switch (issue #12): no null=unmanaged meaning.
# No validation block needed (bool type enforces).
variable "manage_wuauserv" {
  description = "When true, manages the existing wuauserv service (start_type Automatic). Requires prior 'terraform import' (see README). Flipping to false or destroy fails closed via prevent_destroy; use 'terraform state rm' to stop managing."
  type        = bool
  nullable    = false
  default     = false
}
