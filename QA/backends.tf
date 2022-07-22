terraform {
  backend "azurerm" {
    resource_group_name  = "RG_TF_FinalTask"
    storage_account_name = "storageacctfcharnetski"
    #container_name       = "tfstate"
    #key                  = "terraform.tfstate" #join(".", [terraform.workspace ,"terraform.tfstate"])
  }
}