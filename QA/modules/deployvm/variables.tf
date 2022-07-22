variable "suffix" {
  type = string
  default = ""
  description = "A value that is appended to the end of resources"
}

variable "vm_name" {
  type = string
  default = "VM"
  description = "Virtual machine name"
}

variable "rg_location" {
  type = string
  default = "eastus"
  description = "Location of the resources associated with VM"
}

variable "rg_name" {
  type = string
  description = "Resource group name"
}

variable "nic_id" {
  type = string
  description = "Network interface ID"
}

variable "login" {
  type = string
  default = "vmadmin"
  description = "New VM root (admin) default name"
  sensitive = true
}

variable "password" {
  type = string
  default = "Password12345!"
  description = "New VM roog (admin) default password"
  sensitive = true
}

variable "creator" {
  type = string
  default = ""
  description = "A person or group who created tesource"
}