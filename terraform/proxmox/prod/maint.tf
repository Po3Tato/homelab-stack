locals {
  node_names = toset([for k, v in var.vms : v.node_name])
}

module "vms" {
  source          = "../modules/vm"
  for_each        = var.vms
  name            = each.value.name
  vm_id           = each.value.vm_id
  node_name       = each.value.node_name

  clone_vm_id     = each.value.clone_vm_id
  clone_node_name = lookup(each.value, "clone_node_name", each.value.node_name)
  clone_datastore_id = lookup(each.value, "clone_datastore_id", var.datastore_disk)
  full_clone      = lookup(each.value, "full_clone", var.default_full_clone)

  cpu_cores       = each.value.cpu_cores
  cpu_type        = lookup(each.value, "cpu_type", var.default_cpu_type)
  memory          = each.value.memory
  hotplug_cpu     = lookup(each.value, "hotplug_cpu", var.default_hotplug_cpu)
  hotplug_memory  = lookup(each.value, "hotplug_memory", var.default_hotplug_memory)
  hotplugged_vcpu = lookup(each.value, "hotplugged_vcpu", var.default_hotplugged_vcpu)
  max_cpu         = lookup(each.value, "max_cpu", var.default_max_cpu)
  max_memory      = lookup(each.value, "max_memory", var.default_max_memory)
  machine_type    = lookup(each.value, "machine_type", var.default_machine_type)
  viommu          = lookup(each.value, "viommu", var.default_viommu)
  disk_size       = lookup(each.value, "disk_size", null)

  numa            = lookup(each.value, "numa", var.default_numa)
  iothread        = lookup(each.value, "iothread", var.default_iothread)
  ssd_emulation   = lookup(each.value, "ssd_emulation", var.default_ssd_emulation)
  discard         = lookup(each.value, "discard", var.default_discard)

  network_bridge  = var.network_bridge
  vlan_id         = each.value.vlan_id

  datastore_disk  = var.datastore_disk
  agent_enabled   = var.agent_enabled
  vm_reboot       = lookup(each.value, "vm_reboot", var.vm_reboot)
  tags            = concat(["opentofu", "prod-base-img", "linux", "prod"], lookup(each.value, "tags", []))
  hostpci         = lookup(each.value, "hostpci", [])
}
