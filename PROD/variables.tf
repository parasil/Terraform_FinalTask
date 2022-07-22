/*
variable "resource_group_name" {
  default     = "QA"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}*/

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}
/*
variable "enviroment" {
  default     = "QA"
  description = "Enviroment name for using as a prefix to resources and in tags. Can be QA, PROD, etc."
}*/

variable "creator" {
  default     = "Charnetski"
  description = "Resource creator"
}

variable "nsg_rules" {
  type = list(object({
    port       = number
    proto      = string
    priority   = number
    enviroment = string
  }))
  default = [
    {
      port       = 22 #SSH
      proto      = "tcp"
      priority   = 100
      enviroment = "ALL"
    },
    {
      port       = 3389 #RDP
      proto      = "tcp"
      priority   = 200
      enviroment = "ALL"
    },
    {
      port       = 5989 #CIM
      proto      = "tcp"
      priority   = 300
      enviroment = "PROD"
    }
  ]
  description = "List of objects representing ports to open"
}

variable "subnets" {
  type = map(object({
    cidr = string
    name = string
  }))
  default = {
    subnet1 = {
      cidr = "10.0.0.0/24"
      name = "subnet-public"
    },
    subnet2 = {
      cidr = "10.0.1.0/24"
      name = "subnet-private"
    }
  }
  description = "List of subnets to deploy"
}