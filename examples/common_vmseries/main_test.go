package common_vmseries

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/PaloAltoNetworks/terraform-azure-vmseries-modules/go/testskeleton"
)

func TestDeploy(t *testing.T) {
	// prepare random prefix
	randomNames := testskeleton.GenerateAzureRandomNames()

	// define options for Terraform
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		VarFiles:     []string{"example.tfvars"},
		Vars: map[string]interface{}{
			"name_prefix":         randomNames.NamePrefix,
			"resource_group_name": randomNames.ResourceGroupName,
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
