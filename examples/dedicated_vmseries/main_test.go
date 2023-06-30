package dedicated_vmseries

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/PaloAltoNetworks/terraform-azure-vmseries-modules/go/testskeleton"
)

func TestDeploy(t *testing.T) {
	// prepare random prefix
	randomNames := testskeleton.GenerateAzureRandomNames()
	storageDefinition := fmt.Sprintf("{ bootstrap = { name = \"%s\", public_snet_key = \"public\", private_snet_key = \"private\", storage_acl = true, intranet_cidr = \"10.100.0.0/16\", storage_allow_vnet_subnets = { management = { vnet_key = \"transit\", subnet_key = \"management\" } }, storage_allow_inbound_public_ips = [\"1.2.3.4\"] } }", randomNames.StorageAccountName)

	// rename the init-cfg.sample.txt file to init-cfg.txt for test purposes
	os.Rename("files/init-cfg.sample.txt", "files/init-cfg.txt")

	// define options for Terraform
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		VarFiles:     []string{"example.tfvars"},
		Vars: map[string]interface{}{
			"name_prefix":         randomNames.NamePrefix,
			"resource_group_name": randomNames.ResourceGroupName,
			"bootstrap_storage":   storageDefinition,
		},
		Logger:               logger.Default,
		Lock:                 true,
		Upgrade:              true,
		SetVarsAfterVarFiles: true,
	})

	// prepare list of items to check
	assertList := []testskeleton.AssertExpression{}

	// if DO_APPLY is not empty and equal true, then Terraform apply is used, in other case only Terraform plan
	if os.Getenv("DO_APPLY") == "true" {
		// deploy test infrastructure and verify outputs and check if there are no planned changes after deployment
		testskeleton.DeployInfraCheckOutputsVerifyChanges(t, terraformOptions, assertList)
	} else {
		// plan test infrastructure and verify outputs
		testskeleton.PlanInfraCheckErrors(t, terraformOptions, assertList, "No errors are expected")
	}
}

func TestValidate(t *testing.T) {
	testskeleton.ValidateCode(t, nil)
}
