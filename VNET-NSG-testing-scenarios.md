
# Test outcome

for [PR](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/pull/138)

The plan for testing is:

<!-- vscode-markdown-toc -->
* [entry point](#entrypoint)
* [adding a rule in the middle](#addingaruleinthemiddle)
* [change order of rules](#changeorderofrules)
* [delete the 1<sup>st</sup> rule](#deletethe1supstsuprule)
* [conclusion](#conclusion)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=false
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


## <a name='entrypoint'></a>entry point

created two rules like this:

```hcl
network_security_groups = {
  "network_security_group_1" = {
    location = "North Europe"
    rules = {
      "AllOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        protocol                   = "Tcp"
        access                     = "Allow"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowSSH" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
}
```

## <a name='addingaruleinthemiddle'></a>adding a rule in the middle

adding one more rule, so the rules look like this:

``` hcl
network_security_groups = {
  "network_security_group_1" = {
    location = "North Europe"
    rules = {
      "AllOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowRDP" = {
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      "AllowSSH" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
}
```

after running `terraform plan` following output is shown
```bash
Terraform will perform the following actions:

  # module.vnet.azurerm_network_security_group.this["network_security_group_1"] will be updated in-place
  ~ resource "azurerm_network_security_group" "this" {
        id                  = "/subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/fosix-vnet-test/providers/Microsoft.Network/networkSecurityGroups/network_security_group_1"
        name                = "network_security_group_1"
      ~ security_rule       = [
          - {
              - access                                     = "Allow"
              - description                                = ""
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "*"
              - destination_port_ranges                    = []
              - direction                                  = "Outbound"
              - name                                       = "AllOutbound"
              - priority                                   = 100
              - protocol                                   = "Tcp"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
          - {
              - access                                     = "Allow"
              - description                                = ""
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "22"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "AllowSSH"
              - priority                                   = 200
              - protocol                                   = "Tcp"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = ""
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "3389"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "AllowRDP"
              + priority                                   = 300
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = null
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "*"
              + destination_port_ranges                    = []
              + direction                                  = "Outbound"
              + name                                       = "AllOutbound"
              + priority                                   = 100
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = null
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "22"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "AllowSSH"
              + priority                                   = 200
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
        ]
        tags                = {
            "owner" = "fosix"
        }
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

The NSG itself will not be recreated, but the whole ruleset 'inside' NSG will be replaced.

## <a name='changeorderofrules'></a>change order of rules

The input is the same as in the [adding a rule in the middle](adding a rule in the middle), just the order of rules is different. The set of rules from [adding a rule in the middle](adding a rule in the middle) has bwwn already applied to Azure, hence the output of the `terraform plan` command reflects only the order change.

```hcl
network_security_groups = {
  "network_security_group_1" = {
    location = "North Europe"
    rules = {
      "AllowSSH" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      "AllowRDP" = {
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      "AllOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    }
  }
}
```

Below is the `terraform plan` output:

```bash
azurerm_resource_group.this: Refreshing state... [id=/subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/fosix-vnet-test]
module.vnet.azurerm_route_table.this["route_table_1"]: Refreshing state... [id=/subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/fosix-vnet-test/providers/Microsoft.Network/routeTables/route_table_1]
module.vnet.azurerm_virtual_network.this[0]: Refreshing state... [id=/subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/fosix-vnet-test/providers/Microsoft.Network/virtualNetworks/fosix-vnet-nsg-test]
module.vnet.azurerm_network_security_group.this["network_security_group_1"]: Refreshing state... [id=/subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/fosix-vnet-test/providers/Microsoft.Network/networkSecurityGroups/network_security_group_1]
module.vnet.azurerm_subnet.this["management"]: Refreshing state... [id=/subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/fosix-vnet-test/providers/Microsoft.Network/virtualNetworks/fosix-vnet-nsg-test/subnets/management]
module.vnet.azurerm_subnet_network_security_group_association.this["management"]: Refreshing state... [id=/subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/fosix-vnet-test/providers/Microsoft.Network/virtualNetworks/fosix-vnet-nsg-test/subnets/management]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

Hence, the order of the rules does not matter, only the content of the whole set of rules. 

## <a name='deletethe1supstsuprule'></a>delete the 1<sup>st</sup> rule

Just like the topic says, input rules:

```hcl
network_security_groups = {
  "network_security_group_1" = {
    location = "North Europe"
    rules = {
      "AllowRDP" = {
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      "AllOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    }
  }
}
```

`terrafrom plan` output:

```bash
Terraform will perform the following actions:

  # module.vnet.azurerm_network_security_group.this["network_security_group_1"] will be updated in-place
  ~ resource "azurerm_network_security_group" "this" {
        id                  = "/subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/fosix-vnet-test/providers/Microsoft.Network/networkSecurityGroups/network_security_group_1"
        name                = "network_security_group_1"
      ~ security_rule       = [
          - {
              - access                                     = "Allow"
              - description                                = ""
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "*"
              - destination_port_ranges                    = []
              - direction                                  = "Outbound"
              - name                                       = "AllOutbound"
              - priority                                   = 100
              - protocol                                   = "Tcp"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
          - {
              - access                                     = "Allow"
              - description                                = ""
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "22"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "AllowSSH"
              - priority                                   = 200
              - protocol                                   = "Tcp"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
          - {
              - access                                     = "Allow"
              - description                                = ""
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "3389"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "AllowRDP"
              - priority                                   = 300
              - protocol                                   = "Tcp"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = null
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "*"
              + destination_port_ranges                    = []
              + direction                                  = "Outbound"
              + name                                       = "AllOutbound"
              + priority                                   = 100
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = null
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "3389"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "AllowRDP"
              + priority                                   = 300
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
        ]
        tags                = {
            "owner" = "fosix"
        }
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Just like with adding rules, the whole set is replaced. 

## <a name='conclusion'></a>conclusion

It looks like the whole set of rules is treated like an entity. This is coherent with the AzureRM API where you specify a list of rules as a single parameter. The order of the rules does not matter, only the content. 
