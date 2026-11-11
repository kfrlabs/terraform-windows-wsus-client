# Unit tests for the WSUS client module (issue #41).
# Runs fully mocked: no Windows host required.
mock_provider "windows" {}

# --- Defaults: nothing managed -------------------------------------------

run "defaults_manage_nothing" {
  command = plan

  assert {
    condition     = length(output.managed_registry_values) == 0
    error_message = "Defaults should manage no registry values."
  }

  assert {
    condition     = output.wuauserv_managed == false
    error_message = "wuauserv should be unmanaged by default (opt-in)."
  }
}

# --- server_url / status server ------------------------------------------

run "server_url_value" {
  command = plan

  variables {
    server_url = "http://wsus.example.lan:8530"
  }

  assert {
    condition     = output.wu_server == "http://wsus.example.lan:8530"
    error_message = "wu_server output should echo a valid server_url."
  }

  assert {
    condition     = output.status_server == null
    error_message = "status_server should stay null when enable_status_server is null."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\UseWUServer")
    error_message = "UseWUServer should be managed when server_url is set."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\WUServer")
    error_message = "WUServer should be managed when server_url is set."
  }
}

run "server_url_false_disables" {
  command = plan

  variables {
    server_url = "false"
  }

  assert {
    condition     = output.wu_server == null
    error_message = "wu_server output should be null when server_url is \"false\"."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\UseWUServer")
    error_message = "UseWUServer should be managed (\"0\") when server_url is \"false\"."
  }

  assert {
    condition     = !contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\WUServer")
    error_message = "WUServer must be absent when server_url is \"false\"."
  }
}

run "status_server_override" {
  command = plan

  variables {
    server_url           = "http://wsus.example.lan:8530"
    enable_status_server = true
    status_server_url    = "http://status.example.lan:8530"
  }

  assert {
    condition     = output.status_server == "http://status.example.lan:8530"
    error_message = "status_server output should follow status_server_url when set."
  }
}

run "status_server_override_invalid_rejected" {
  command = plan

  variables {
    server_url           = "http://wsus.example.lan:8530"
    enable_status_server = true
    status_server_url    = "not-a-url"
  }

  expect_failures = [
    var.status_server_url,
  ]
}

run "update_service_url_alternate" {
  command = plan

  variables {
    update_service_url_alternate = "http://cdn.example.lan:8530"
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\UpdateServiceUrlAlternate")
    error_message = "UpdateServiceUrlAlternate should be managed when set."
  }
}

run "update_service_url_alternate_invalid_rejected" {
  command = plan

  variables {
    update_service_url_alternate = "not-a-url"
  }

  expect_failures = [
    var.update_service_url_alternate,
  ]
}

run "modern_booleans" {
  command = plan

  variables {
    disable_dual_scan                       = true
    do_not_enforce_tls_cert_pinning         = false
    set_proxy_behavior_for_update_detection = true
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\DisableDualScan")
    error_message = "DisableDualScan should be managed when true."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\DoNotEnforceEnterpriseTLSCertPinningForUpdateDetection")
    error_message = "DoNotEnforceEnterpriseTLSCertPinningForUpdateDetection should be managed when false."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\SetProxyBehaviorForUpdateDetection")
    error_message = "SetProxyBehaviorForUpdateDetection should be managed when true."
  }
}

run "status_server_requires_url" {
  command = plan

  variables {
    enable_status_server = true
  }

  expect_failures = [
    var.enable_status_server,
  ]
}

run "status_server_follows_url" {
  command = plan

  variables {
    server_url           = "http://wsus.example.lan:8530"
    enable_status_server = true
  }

  assert {
    condition     = output.status_server == "http://wsus.example.lan:8530"
    error_message = "status_server output should follow server_url when enabled."
  }
}

# --- AUOptions / schedule mapping ----------------------------------------

run "au_options_name_maps_to_dword" {
  command = plan

  variables {
    auto_update_option     = "Scheduled"
    scheduled_install_day  = "Tuesday"
    scheduled_install_hour = 2
  }

  assert {
    condition     = output.au_options_effective == 4
    error_message = "Scheduled should map to AUOptions DWORD 4."
  }

  assert {
    condition     = output.scheduled_install_day_effective == 3
    error_message = "Tuesday should map to ScheduledInstallDay DWORD 3."
  }
}

run "au_options_numeric_string" {
  command = plan

  variables {
    auto_update_option     = "4"
    scheduled_install_day  = "Tuesday"
    scheduled_install_hour = 2
  }

  assert {
    condition     = output.au_options_effective == 4
    error_message = "Numeric auto_update_option \"4\" should pass through as a number."
  }
}

run "au_options_invalid_rejected" {
  command = plan

  variables {
    auto_update_option = "9"
  }

  expect_failures = [
    var.auto_update_option,
  ]
}

run "scheduled_requires_day_and_hour" {
  command = plan

  variables {
    auto_update_option = "Scheduled"
  }

  expect_failures = [
    var.auto_update_option,
  ]
}

run "schedule_without_scheduled_rejected" {
  command = plan

  variables {
    scheduled_install_day = "Tuesday"
  }

  expect_failures = [
    var.auto_update_option,
  ]
}

run "hour_without_scheduled_rejected" {
  command = plan

  variables {
    scheduled_install_hour = 2
  }

  expect_failures = [
    var.auto_update_option,
  ]
}

run "reschedule_requires_scheduled" {
  command = plan

  variables {
    reschedule_wait_time_minutes = "5"
  }

  expect_failures = [
    var.reschedule_wait_time_minutes,
  ]
}

# --- Value/Enabled pairs ---------------------------------------------------

run "pair_false_disables_only" {
  command = plan

  variables {
    detection_frequency_hours = "false"
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\DetectionFrequencyEnabled")
    error_message = "DetectionFrequencyEnabled should be managed when detection_frequency_hours is \"false\"."
  }

  assert {
    condition     = !contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\DetectionFrequency")
    error_message = "DetectionFrequency value must be absent when detection_frequency_hours is \"false\"."
  }
}

run "pair_value_enables" {
  command = plan

  variables {
    reboot_warning_timeout_minutes = "5"
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\RebootWarningTimeout")
    error_message = "RebootWarningTimeout value should be managed for \"5\"."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\RebootWarningTimeoutEnabled")
    error_message = "RebootWarningTimeoutEnabled should be managed for \"5\"."
  }
}

run "boolean_true_and_false" {
  command = plan

  variables {
    no_auto_update             = true
    auto_install_minor_updates = false
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\NoAutoUpdate")
    error_message = "NoAutoUpdate should be managed when true."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\AutoInstallMinorUpdates")
    error_message = "AutoInstallMinorUpdates should be managed when false."
  }
}

run "target_group_case_variant_rejected" {
  command = plan

  variables {
    target_group = "False"
  }

  expect_failures = [
    var.target_group,
  ]
}

run "target_group_false_disables_only" {
  command = plan

  variables {
    target_group = "false"
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\TargetGroupEnabled")
    error_message = "TargetGroupEnabled should be managed when target_group is \"false\"."
  }

  assert {
    condition     = !contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\TargetGroup")
    error_message = "TargetGroup value must be absent when target_group is \"false\"."
  }
}

run "target_group_value_enables" {
  command = plan

  variables {
    target_group = "Servers"
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\TargetGroup")
    error_message = "TargetGroup value should be managed for \"Servers\"."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\TargetGroupEnabled")
    error_message = "TargetGroupEnabled should be managed for \"Servers\"."
  }
}

# --- Active Hours ----------------------------------------------------------

run "active_hours_both_false" {
  command = plan

  variables {
    active_hours_start = "false"
    active_hours_end   = "false"
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\SetActiveHours")
    error_message = "SetActiveHours should be managed when Active Hours are \"false\"."
  }

  assert {
    condition     = !contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\ActiveHoursStart")
    error_message = "ActiveHoursStart must be absent when Active Hours are \"false\"."
  }
}

run "active_hours_numeric_pair" {
  command = plan

  variables {
    active_hours_start = "8"
    active_hours_end   = "18"
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\SetActiveHours")
    error_message = "SetActiveHours should be managed for a numeric Active Hours pair."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\ActiveHoursStart")
    error_message = "ActiveHoursStart should be managed for a numeric Active Hours pair."
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\ActiveHoursEnd")
    error_message = "ActiveHoursEnd should be managed for a numeric Active Hours pair."
  }
}

run "active_hours_single_sided_rejected" {
  command = plan

  variables {
    active_hours_start = "8"
  }

  expect_failures = [
    var.active_hours_end,
  ]
}

run "active_hours_equal_rejected" {
  command = plan

  variables {
    active_hours_start = "8"
    active_hours_end   = "8"
  }

  expect_failures = [
    var.active_hours_end,
  ]
}

run "active_hours_overlong_range_rejected" {
  command = plan

  variables {
    active_hours_start = "8"
    active_hours_end   = "3"
  }

  expect_failures = [
    var.active_hours_end,
  ]
}

# --- Reboot minutes (plain number) ------------------------------------------

run "reboot_minutes_value" {
  command = plan

  variables {
    always_auto_reboot_at_scheduled_time_minutes = 30
  }

  assert {
    condition     = contains(output.managed_registry_values, "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\AlwaysAutoRebootAtScheduledTimeMinutes")
    error_message = "AlwaysAutoRebootAtScheduledTimeMinutes should be managed for 30."
  }
}

run "reboot_minutes_out_of_range_rejected" {
  command = plan

  variables {
    always_auto_reboot_at_scheduled_time_minutes = 5
  }

  expect_failures = [
    var.always_auto_reboot_at_scheduled_time_minutes,
  ]
}
