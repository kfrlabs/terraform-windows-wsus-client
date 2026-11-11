variable "server_url" {
  description = "WSUS server URL (http(s)://...). \"false\" disables UseWUServer. null leaves settings unmanaged."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.server_url == null || var.server_url == "false" || can(regex("^https?://", var.server_url))
    error_message = "server_url must be null, \"false\", or a valid http(s) URL."
  }
}

variable "enable_status_server" {
  # Cross-variable rule (PLAN.md §4, enforced via lifecycle precondition in main.tf – step 2):
  # true requires server_url to be a valid URL. Terraform variable validation
  # cannot reference other variables.
  description = "When true, WUStatusServer follows server_url. null leaves it unmanaged."
  type        = bool
  nullable    = true
  default     = null
}

variable "auto_update_option" {
  # Cross-variable rule (PLAN.md §4, precondition in main.tf – step 2):
  # "Scheduled"/"4" requires scheduled_install_day and scheduled_install_hour.
  description = "AUOptions mode. Puppet names or DWORD values as string: NotifyOnly/2, AutoNotify/3, Scheduled/4, AutoInstall/5, NotifyRestart/7 (2016+)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.auto_update_option == null ? true : contains(["NotifyOnly", "AutoNotify", "Scheduled", "AutoInstall", "NotifyRestart", "2", "3", "4", "5", "7"], var.auto_update_option)
    error_message = "auto_update_option must be one of: NotifyOnly, AutoNotify, Scheduled, AutoInstall, NotifyRestart, 2, 3, 4, 5, 7."
  }
}

variable "scheduled_install_day" {
  description = "Scheduled install day. Puppet names or DWORD values as string: Everyday/0 ... Saturday/7."
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
}

variable "target_group" {
  description = "Target group name (TargetGroup). null unmanaged, \"false\" disables (Enabled=0 only)."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.target_group == null ? true : (var.target_group != "" && trimspace(var.target_group) != "")
    error_message = "target_group must be null, \"false\", or a non-empty string."
  }
}
