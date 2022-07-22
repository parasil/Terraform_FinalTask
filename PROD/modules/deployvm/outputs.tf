output "vm_id" {
  description = "Virtual machine ID"
  value       = azurerm_virtual_machine.VM.id #aws_instance.my-instance.private_ip
}