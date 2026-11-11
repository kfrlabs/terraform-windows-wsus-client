# ADR 0001 — Variable typing for `false` / `null`

- Status: accepted.
- Scope: `variables.tf` (already conforming, read-only check).

## Context

Most settings support three
states: a value, `false` (explicitly disabled), or `null` (unmanaged).
Terraform variables need one static type per variable, with `null` as the
default (unmanaged). The decision covers every
value-or-`false` parameter: `server_url`,
`detection_frequency_hours`, `reboot_relaunch_timeout_minutes`,
`reboot_warning_timeout_minutes`, `reschedule_wait_time_minutes`,
`always_auto_reboot_at_scheduled_time_minutes`,
`active_hours_start`/`active_hours_end`, `target_group`; plus the 7 plain
booleans and the `scheduled_install_hour` exception.

## Considered options

1. **Nullable `string` with `"false"` = disabled (chosen).** Numeric or
   group-name values stay strings; `"false"` means disabled; `null` means
   unmanaged. Validation accepts `null`, `"false"`, or a numeric string
   in range (`tonumber()` at use site).
2. **Nullable `number` plus a separate boolean variable per parameter.**
   Rejected: verbose (one extra variable per setting), diverges from the
   established interface (`false` as a value, not a second flag), and breaks
   Registry documentation consistency.
3. **`any` (number or bool).** Rejected: produces poor Registry
   documentation (type renders as `any`), weakens `validation {}` blocks,
   and pushes type errors to `plan`/`apply` instead of input validation.

## Decision

- Option 1 for all value-or-`false` parameters: nullable `string`,
  `"false"` = disabled.
- The 7 plain booleans stay nullable `bool`:
  `accept_trusted_publisher_certs`, `auto_install_minor_updates`,
  `disable_windows_update_access`, `elevate_non_admins`,
  `no_auto_reboot_with_logged_on_users`, `no_auto_update`,
  `always_auto_reboot_at_scheduled_time`.
- Exception: `scheduled_install_hour` stays `number` (`0-23`) — there is
  no `false` meaning for this key on the registry side. Same exception
  applies to `always_auto_reboot_at_scheduled_time_minutes` (`number`,
  `15-180`): the key has no `Enabled` companion, so `"false"` was
  equivalent to `null` and the sentinel was dropped (issue #44).
- Semantics for `Value`/`Enabled` pairs:
  - `null` → unmanaged, no resources (`count = 0`);
  - `"false"` (exact lowercase, case-sensitive) → `<Key>Enabled = "0"` only, value resource absent;
  - value → `<Key> = value` + `<Key>Enabled = "1"`.
- Edge case: `target_group = "false"` means disabled
  (`TargetGroupEnabled = "0"`), so the literal group name `"false"` is
  unusable. This is documented (`false` disables the setting).
  `"False"` would create a group of that name instead of disabling;
  #11/#4 to enforce or normalize.
- `active_hours_start`/`active_hours_end` pair must be both `null`,
  both `"false"`, or both numeric; mixed `"false"`/numeric is rejected
  by #11 validation.

## Consequences

- Issue #5 (`locals` mapping): convert with `tonumber()` only after
  excluding `null` and `"false"`.
- Issue #11 (cross-variable validation): preconditions work on the
  `string` form (`"Scheduled"`/`"4"`, `active_hours_start` with
  `active_hours_end`, `enable_status_server = true` requiring a
  `server_url` URL).
- `variables.tf` already conforms to option 1 (verified read-only);
  no retyping required.
- Traceability aligned, referenced by #4, #8, #9, #10.
