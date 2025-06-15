variable "vms" {
  description = "Map of VMs with their configurations"
  type = map(object({
    node_name           = string
    name                = string
    vm_id               = number
    cpu_cores           = number
    memory              = number
    disk_size           = optional(number)
    vlan_id             = number
    vm_reboot           = optional(bool)
    cpu_type            = optional(string)
    hotplug_cpu         = optional(bool)
    hotplug_memory      = optional(bool)
    max_cpu             = optional(number)
    max_memory          = optional(number)
    machine_type        = optional(string)
    viommu              = optional(string)
    tags                = optional(list(string), [])
    clone_vm_id         = number
    clone_node_name     = optional(string)
    clone_datastore_id  = optional(string)
    full_clone          = optional(bool)
    discard             = optional(string)
    hostpci = optional(list(object({
      device = string
      mapping     = string
      pcie   = optional(bool)
      rombar = optional(bool)
      xvga   = optional(bool)
    })), [])
  }))
}

variable "node_name" {
  description = "Default Proxmox node name"
  type        = string
}

variable "datastore_disk" {
  description = "Datastore for VM disks"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge to use"
  type        = string
  default     = "vmbr0"
}

variable "virtual_environment_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "virtual_environment_api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "vm_reboot" {
  description = "Reboot VM after creation"
  type        = bool
  default     = false
}

variable "agent_enabled" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = true
}

variable "default_hotplug_cpu" {
  description = "Default setting for CPU hotplug"
  type        = bool
  default     = false
}

variable "default_hotplug_memory" {
  description = "Default setting for memory hotplug"
  type        = bool
  default     = false
}

variable "default_max_cpu" {
  description = "Default maximum CPU cores for hotplug"
  type        = number
  default     = 4
}

variable "default_max_memory" {
  description = "Default maximum memory in MB for hotplug"
  type        = number
  default     = 8192
}

variable "default_machine_type" {
  description = "Default machine type for VMs"
  type        = string
  default     = "pc"
}

variable "default_viommu" {
  description = "Default vIOMMU setting (empty string for disabled)"
  type        = string
  default     = ""
}

variable "default_full_clone" {
  description = "Default setting for full clone or linked clone"
  type        = bool
  default     = true
}

variable "default_cpu_type" {
  description = "Default CPU type if not specified per-VM."
  type        = string
  default     = "x86-64-v2-AES"
}

variable "default_numa" {
  description = "Default NUMA setting if not specified per-VM."
  type        = bool
  default     = true
}

variable "default_iothread" {
  description = "Default iothread setting for disks if not specified per-VM."
  type        = bool
  default     = true
}

variable "default_ssd_emulation" {
  description = "Default SSD emulation setting for disks if not specified per-VM."
  type        = bool
  default     = true
}


variable "default_discard" {
  description = "Default discard setting for disks if not specified per-VM."
  type        = string
  default     = "on"
  validation {
    condition     = contains(["on", "ignore"], var.default_discard)
    error_message = "Default discard must be either 'on' or 'ignore'."
  }
}
