variable "windows_host" {
  description = "Windows target host (hostname or IP)."
  type        = string
}

variable "windows_username" {
  description = "Username for the Windows provider connection."
  type        = string
}

variable "windows_password" {
  description = "Password for the Windows provider connection. Leave unset when using key-based auth via environment variables."
  type        = string
  sensitive   = true
  default     = null
}
