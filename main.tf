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

  # Provisional helpers for the core resources (issue #6 reuses them).
  # Exact lowercase "false" only (ADR-0001, case-sensitive).
  is_wus_disabled = var.server_url == "false"
  is_wus_url      = var.server_url != null && var.server_url != "false"
}

# NOTE: cross-variable lifecycle preconditions (enable_status_server
# requiring a server_url URL, Scheduled requiring day + hour) will be
# enforced here in issue #11. Placeholder only — no preconditions yet.
