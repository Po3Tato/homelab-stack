terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.1"
    }
  }
}

provider "proxmox" {
  endpoint  = var.virtual_environment_endpoint
  api_token = var.virtual_environment_api_token
  insecure  = true
  
  ssh {
    agent       = false
    private_key = file("~/.ssh/id_rsa")
    username    = "root"
  }
}
