# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "transit-vnet-brownfield"
name_prefix         = "fosix-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}


# --- VNET PART --- #
vnets = {
  simple = {
    name          = "simple-vnet"
    address_space = ["10.100.0.0/24"]
  }
  subnetted = {
    name          = "subnetted-vnet"
    address_space = ["10.100.1.0/24"]
    subnets = {
      subnet_a = {
        name                            = "subnet_a"
        address_prefixes                = ["10.100.1.0/25"]
        enable_storage_service_endpoint = true
      }
      subnet_b = {
        name             = "subnet_b"
        address_prefixes = ["10.100.1.128/25"]
      }
    }
  }
}
