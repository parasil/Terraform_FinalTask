
#deploy vm in public subnet
module "vm1" {
  source = "./modules/deployvm"
  #region = var.region
  vm_name     = "VM-public"
  suffix      = terraform.workspace
  rg_location = azurerm_resource_group.rg.location
  rg_name     = azurerm_resource_group.rg.name
  nic_id      = azurerm_network_interface.NIC-public.id
  creator     = var.creator
}

#deploy vm in private subnet
module "vm2" {
  source = "./modules/deployvm"
  #region = var.region
  vm_name     = "VM-private"
  suffix      = terraform.workspace
  rg_location = azurerm_resource_group.rg.location
  rg_name     = azurerm_resource_group.rg.name
  nic_id      = azurerm_network_interface.NIC-private.id
  creator     = var.creator
}

#resource "random_pet" "rg-name" {
#  prefix    = var.resource_group_name_prefix
#}

#Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = join("-", ["RG", terraform.workspace])
  location = var.resource_group_location
  tags = {
    Environment = terraform.workspace
    CreatedBy   = var.creator
  }
}

#Create NSG
resource "azurerm_network_security_group" "NSG" {
  name                = join("-", ["NSG", terraform.workspace])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = local.nsg_rules_final #var.nsg_rules
    content {
      name                       = join("-", ["Inbound", security_rule.value.port])
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.proto
      source_port_range          = security_rule.value.port
      destination_port_range     = security_rule.value.port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  tags = {
    Environment = terraform.workspace
    CreatedBy   = var.creator
  }
}

# Create virtual network
resource "azurerm_virtual_network" "VNet" {
  name                = join("-", ["VNet", terraform.workspace])
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Environment = terraform.workspace
    CreatedBy   = var.creator
  }
}

# Create subnets
resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = join("-", [each.value["name"], terraform.workspace])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VNet.name
  address_prefixes     = [each.value["cidr"]]
}
/*
resource "azurerm_subnet" "subnet-private" {
  name                 = join("-", ["subnet-private", terraform.workspace])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VNet.name
  address_prefix       = "10.0.1.0/24"

}
*/

#Deploy Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = join("-", ["pubip", terraform.workspace]) #"pubip1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    Environment = terraform.workspace
    CreatedBy   = var.creator
  }
}

#Create public NIC
resource "azurerm_network_interface" "NIC-public" {
  name                = join("-", ["NIC-public", terraform.workspace])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # network_security_group_id = azurerm_network_security_group.NSG.id #assign NSG

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnets["subnet1"].id #azurerm_subnet.subnet-private.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    Environment = terraform.workspace
    CreatedBy   = var.creator
  }
}

#Create private NIC
resource "azurerm_network_interface" "NIC-private" {
  name                = join("-", ["NIC-private", terraform.workspace])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # network_security_group_id = azurerm_network_security_group.NSG.id #assign NSG

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnets["subnet2"].id #azurerm_subnet.subnet-private.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    Environment = terraform.workspace
    CreatedBy   = var.creator
  }
}


#Associate subnet with NSG
resource "azurerm_subnet_network_security_group_association" "nsg_to_subnet_association" {
  subnet_id                 = azurerm_subnet.subnets["subnet1"].id
  network_security_group_id = azurerm_network_security_group.NSG.id
}


#Create Virtual Machine
/*resource "azurerm_virtual_machine" "VM" {
  name                             = join("-", ["VM-private", terraform.workspace]) #"VM-private"  
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.NIC-public.id]
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
    name              = join("-", ["osdisk1", terraform.workspace])
    disk_size_gb      = "128"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = join("-", ["VM-private", terraform.workspace])
    admin_username = "vmadmin"
    admin_password = "Password12345!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    Environment = terraform.workspace
    CreatedBy   = var.creator
  }
}*/

locals {
  nsg_rules_all      = { for k, v in var.nsg_rules : k => v if v.enviroment == "ALL" }               #rules for all workspaces
  nsg_rules_specific = { for k, v in var.nsg_rules : k => v if v.enviroment == terraform.workspace } #rules specific to current workspace
  nsg_rules_final    = merge(local.nsg_rules_all, local.nsg_rules_specific)
}

