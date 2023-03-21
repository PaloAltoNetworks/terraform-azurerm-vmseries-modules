# Palo Alto Networks Application Insights Module for Azure

A Terraform module for deploying a Application Insights in Azure cloud.

Azure AI can be used to gather metric from Palo Alto's VMSeries firewall. This can be done for both a standalone firewall as for a Scale Set deployment.

In both situations the instrumentation key for the Application Insights has to be provided in the firewall's configuration. For more information please refer to [documentation](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/enable-azure-application-insights-on-the-vm-series-firewall).


**NOTICE**

 * Azure support for classic Application Insights mode will end on Feb 29th 2024. It's already not available in some of the new regions. This module by default deploys Application Insights in Workspace mode.

* The metrics gathered within a single Azure Application Insights instance provided by the module, cannot be split to obtain
back a result for solely a single firewall. Thus for example if three firewalls use the same Instrumentation Key and report
their respective session utilizations as 90%, 20%, 10%, it is possible to see in Azure the average of 40%, the sum of 120%, the max of 90%, but it is *not possible* to know which of the firewalls reported the 90% utilization.

* Since upgrade to provider 3.x, when destroying infrastructure with a resource is being left behind: `microsoft.alertsmanagement/smartdetectoralertrules`. This resource is not present in the state nor code, it's being created by Azure automatically and therefore it prevents resource group deletion. A workaround is to set the following provider configuration:

      provider "azurerm" {
        features {
          resource_group {
            prevent_deletion_if_contains_resources = false
          }
        }
      }

## Usage

The following snippet deploys Application Insights in Workspace mode, setting the retention to 1 year.

```hcl
module "ai" {
  source = "../../modules/application_insights"

  name                      = "vmseries-ai
  metrics_retention_in_days = 365
  location                  = "West US"
  resource_group_name       = "vmseries-rg"
}
```  

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
