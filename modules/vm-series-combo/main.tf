/*
* # networking terraform module
* 
* A terraform module for deploying standalone (non-scale-set) VM series firewalls in Azure.
* 
* This module deploys both Inbound and Outbound VM-series firewalls as the one module.
* 
* # Usage
* 
* ```hcl
* module "vm-series" {
*   source      = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vm-series-combo"
*   location    = "Australia Central"
*   name_prefix = "panostf"
*   password    = "your-password"
*   subnet-mgmt    = azurerm_subnet.subnet-mgmt
*   subnet-private = azurerm_subnet.subnet-private
*   subnet-public  = module.networks.subnet-public
*   bootstrap-storage-account     = module.panorama.bootstrap-storage-account
*   inbound-bootstrap-share-name  = "inboundsharename"
*   outbound-bootstrap-share-name = "outboundsharename"
*   vhd-container           = "vhd-storage-container-name"
*   private_backend_pool_id = "private-backend-pool-id"
*   public_backend_pool_id  = "public-backend-pool-id"
* }
* ```
*/