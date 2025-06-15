terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

locals {
  safe_hotplug_cpu    = var.hotplug_cpu == null ? false : var.hotplug_cpu
  safe_hotplug_memory = var.hotplug_memory == null ? false : var.hotplug_memory
  safe_max_cpu        = var.max_cpu == null ? var.cpu_cores : var.max_cpu
  safe_max_memory     = var.max_memory == null ? var.memory : var.max_memory
  safe_machine_type   = var.machine_type == null ? "pc" : var.machine_type
  safe_viommu         = var.viommu == null ? "" : var.viommu
}

resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.name
  description = "Managed by OpenTofu"
  tags        = var.tags
  node_name   = var.node_name
  vm_id       = var.vm_id

  clone {
    vm_id        = var.clone_vm_id
    node_name    = var.clone_node_name
    datastore_id = var.clone_datastore_id
    full         = var.full_clone
    retries      = 3
  }

  agent {
    enabled = var.agent_enabled
    trim    = true
    type    = "virtio"
  }

  reboot           = var.vm_reboot
  stop_on_destroy  = true
  on_boot          = true
  machine = local.safe_viommu != "" ? "${local.safe_machine_type},viommu=${local.safe_viommu}" : local.safe_machine_type

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    sockets    = 1
    cores      = var.cpu_cores
    type       = var.cpu_type
    numa       = local.safe_hotplug_cpu
    hotplugged = local.safe_hotplug_cpu ? (local.safe_max_cpu - var.cpu_cores) : 0
    flags      = local.safe_hotplug_cpu ? ["+pcid", "+aes"] : ["+aes"]
    units      = 1024
  }

  memory {
    dedicated = var.memory
    floating  = local.safe_hotplug_memory ? var.memory : 0
    shared    = 0
  }

  dynamic "disk" {
    for_each = var.disk_size != null ? [1] : []
    content {
      interface    = "scsi0"
      size         = var.disk_size
      datastore_id = var.datastore_disk
    }
  }

  network_device {
    bridge  = var.network_bridge
    model   = "virtio"
    vlan_id = var.vlan_id != null ? var.vlan_id : 0
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  dynamic "hostpci" {
    for_each = var.hostpci
    content {
      device  = hostpci.value.device
      mapping = hostpci.value.mapping
      pcie    = lookup(hostpci.value, "pcie", false)
      rombar  = lookup(hostpci.value, "rombar", true)
      xvga    = lookup(hostpci.value, "xvga", false)
    }
  }

  timeout_clone        = 1800
  timeout_create       = 600
  timeout_migrate      = 1800
  timeout_reboot       = 1800
  timeout_shutdown_vm  = 1800
  timeout_start_vm     = 1800
  timeout_stop_vm      = 300
}
