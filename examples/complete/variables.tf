variable "windows_host" {
  description = "Windows target host (hostname or IP)."
  type        = string
}

variable "windows_username" {
  description = "Username for the Windows provider connection."
  type        = string
}

variable "windows_private_key_path" {
  description = "Path to the SSH private key for the Windows provider connection. Leave unset to use the WINDOWS_PRIVATE_KEY_PATH environment variable."
  type        = string
  default     = null
}
