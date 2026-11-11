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
    condition     = var.auto_update_option == null || contains(["NotifyOnly", "AutoNotify", "Scheduled", "AutoInstall", "NotifyRestart", "2", "3", "4", "5", "7"], var.auto_update_option)
    error_message = "auto_update_option must be one of: NotifyOnly, AutoNotify, Scheduled, AutoInstall, NotifyRestart, 2, 3, 4, 5, 7."
  }
}

variable "scheduled_install_day" {
  description = "Scheduled install day. Puppet names or DWORD values as string: Everyday/0 ... Saturday/7."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.scheduled_install_day == null || contains(["Everyday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "0", "1", "2", "3", "4", "5", "6", "7"], var.scheduled_install_day)
    error_message = "scheduled_install_day must be one of: Everyday, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, 0-7."
  }
}

variable "scheduled_install_hour" {
  description = "Scheduled install hour, 0-23 (maps to ScheduledInstallTime)."
  type        = number
  nullable    = true
  default     = null

  validation {
    condition     = var.scheduled_install_hour == null || (var.scheduled_install_hour >= 0 && var.scheduled_install_hour <= 23 && floor(var.scheduled_install_hour) == var.scheduled_install_hour)
    error_message = "scheduled_install_hour must be an integer between 0 and 23."
  }
}
