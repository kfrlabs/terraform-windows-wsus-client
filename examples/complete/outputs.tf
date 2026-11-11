output "wu_unknown_value_names" {
  description = "Unmanaged values under the WindowsUpdate root key (purge preview)."
  value       = module.wsus_client.wu_unknown_value_names
}

output "au_unknown_value_names" {
  description = "Unmanaged values under the WindowsUpdate\\AU subkey (purge preview)."
  value       = module.wsus_client.au_unknown_value_names
}
