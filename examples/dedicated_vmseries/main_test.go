package dedicated_vmseries

import (
	"fmt"
	"log"
	"os"
	"testing"

	"github.com/PaloAltoNetworks/terraform-modules-vmseries-tests-skeleton/pkg/testskeleton"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func CreateTerraformOptions(t *testing.T) *terraform.Options {
	// prepare random prefix
	randomNames := testskeleton.GenerateAzureRandomNames()
	storageDefinition := fmt.Sprintf("{ bootstrap = { name = \"%s\", public_snet_key = \"public\", private_snet_key = \"private\", intranet_cidr = \"10.0.0.0/25\"} }", randomNames.StorageAccountName)

	// copy the init-cfg.sample.txt file to init-cfg.txt for test purposes
	_, err := os.Stat("files/init-cfg.txt")
	if err != nil {
		buff, err := os.ReadFile("files/init-cfg.sample.txt")
		if err != nil {
			log.Fatal(err)
		}
		err = os.WriteFile("files/init-cfg.txt", buff, 0644)
		if err != nil {
			log.Fatal(err)
		}
	}

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

	return terraformOptions
}

func TestValidate(t *testing.T) {
	testskeleton.ValidateCode(t, nil)
}

func TestPlan(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)
	// prepare list of items to check
	assertList := []testskeleton.AssertExpression{}
	// plan test infrastructure and verify outputs
	testskeleton.PlanInfraCheckErrors(t, terraformOptions, assertList, "No errors are expected")
}

func TestApply(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)
	// prepare list of items to check
	assertList := []testskeleton.AssertExpression{}
	// deploy test infrastructure and verify outputs and check if there are no planned changes after deployment
	testskeleton.DeployInfraCheckOutputs(t, terraformOptions, assertList)
}

func TestIdempotence(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)
	// prepare list of items to check
	assertList := []testskeleton.AssertExpression{}
	// deploy test infrastructure and verify outputs and check if there are no planned changes after deployment
	testskeleton.DeployInfraCheckOutputsVerifyChanges(t, terraformOptions, assertList)
}
