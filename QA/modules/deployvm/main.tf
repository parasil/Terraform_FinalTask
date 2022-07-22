#Create Virtual Machine
resource "azurerm_virtual_machine" "VM" {
  name                             = join("-", [var.vm_name, var.suffix]) #"VM-private"  
  location                         = var.rg_location #azurerm_resource_group.rg.location
  resource_group_name              = var.rg_name #azurerm_resource_group.rg.name
  network_interface_ids            = [var.nic_id]#[azurerm_network_interface.NIC-public.id]
  vm_size                          = "Standard_B1s"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = join("-", ["osdisk", var.vm_name, var.suffix])
    disk_size_gb      = "128"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = join("-", [var.vm_name, var.suffix])
    admin_username = var.login
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    Environment = var.suffix
    CreatedBy   = var.creator
  }
}