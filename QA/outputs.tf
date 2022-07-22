output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vm1_name" {
  value = module.vm1.vm_id
}

output "vm2_name" {
  value = module.vm2.vm_id
}