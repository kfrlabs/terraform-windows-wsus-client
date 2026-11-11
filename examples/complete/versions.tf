terraform {
  required_version = ">= 1.11"

  required_providers {
    windows = {
      source  = "kfrlabs/windows"
      version = ">= 0.4.0, < 0.5.0"
    }
  }
}
