variable "name" {
  description = "Name for the VM"
  type        = string
}

variable "vm_id" {
  description = "VM ID"
  type        = number
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "clone_vm_id" {
  description = "VM ID to clone from"
  type        = number
}

variable "clone_node_name" {
  description = "Node name where the source VM resides"
  type        = string
}

variable "clone_datastore_id" {
  description = "Datastore for cloned disks"
  type        = string
}

variable "full_clone" {
  description = "Whether to perform a full clone"
  type        = bool
  default     = true
}

variable "cpu_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
}

variable "cpu_type" {
  description = "CPU type for the VM"
  type        = string
  default     = "host"
}

variable "memory" {
  description = "Memory in MB for the VM"
  type        = number
}

variable "disk_size" {
  description = "Disk size in GB (optional, for resizing)"
  type        = number
  default     = null
}

variable "datastore_disk" {
  description = "Datastore for VM disks"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge to use"
  type        = string
}

variable "vlan_id" {
  description = "VLAN ID for network interface"
  type        = number
  default     = null
}

variable "agent_enabled" {
  description = "Enable the QEMU guest agent"
  type        = bool
  default     = true
}

variable "vm_reboot" {
  description = "Whether to reboot the VM after creation"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to assign to the VM"
  type        = list(string)
  default     = ["opentofu"]
}

variable "numa" {
  description = "Enable or disable NUMA support for the virtual machine."
  type        = bool
  default     = true
}

variable "hotplug_cpu" {
  description = "Whether to enable CPU hotplug"
  type        = bool
  default     = false
}

variable "iothread" {
  description = "Enable or disable I/O thread for the primary disk."
  type        = bool
  default     = true
}

variable "ssd_emulation" {
  description = "Enable SSD emulation for the primary disk."
  type        = bool
  default     = true
}

variable "hotplug_memory" {
  description = "Whether to enable memory hotplug"
  type        = bool
  default     = false
}

variable "max_cpu" {
  description = "Maximum number of CPU cores for hotplug"
  type        = number
  default     = null
}

variable "max_memory" {
  description = "Maximum memory in MB for hotplug"
  type        = number
  default     = null
}

variable "hotplugged_vcpu" {
  description = "Number of hotplugged vCPUs (explicit count)"
  type        = number
  default     = null
}

variable "machine_type" {
  description = "Machine type for the VM"
  type        = string
  default     = "pc"
}

variable "viommu" {
  description = "VIOMMU type"
  type        = string
  default     = ""
}

variable "discard" {
  description = "Whether to pass discard/trim requests to the underlying storage"
  type        = string
  default     = "on"
  validation {
    condition     = contains(["on", "ignore"], var.discard)
    error_message = "Discard must be either 'on' or 'ignore'."
  }
}

variable "hostpci" {
  description = "List of host PCI devices to pass through"
  type = list(object({
    device  = string
    mapping = string
    pcie    = optional(bool, false)
    rombar  = optional(bool, true)
    xvga    = optional(bool, false)
  }))
  default = []
}
