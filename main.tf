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

# NOTE: cross-variable lifecycle preconditions (enable_status_server
# requiring a server_url URL, Scheduled requiring day + hour) will be
# enforced here in issue #11. Placeholder only — no preconditions yet.
