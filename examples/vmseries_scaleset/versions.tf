terraform {
  required_version = ">= 0.12.29, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine_scale_set {
      # Make upgrade_policy_mode = "Manual" actually work. On a default setting:
      # The image version or the user data cannot be modified on a scale set. Despite the Upgrade Mode being "Manual",
      # each vm is rebooted in a rolling-like manner. The health probe is not used and the rolling-like reboot does not
      # have any "cooldown" time. The impact is that for about 5 minutes the freshly rebooted VM-Series is not able to
      # handle the load. With 3 VMs it is a degradation, but with 2 VMs it would be a loss of production traffic.
      # Tests show one VM down while another "running" VM cannot even accept SSH management traffic for many more
      # minutes, because contrary to what Azure assumes it has not booted yet.
      # Tested on panos 10.0.6 and azurerm provider 2.64.
      roll_instances_when_required = false
    }
  }
}
