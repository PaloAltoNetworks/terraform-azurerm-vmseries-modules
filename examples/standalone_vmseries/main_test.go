package centralized_design

import (
	"fmt"
	"math/rand"
	"os"
	"testing"
	"time"

	"github.com/PaloAltoNetworks/terraform-azure-vmseries-modules/go/testskeleton"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestDeploy(t *testing.T) {
	// prepare random prefix
	source := rand.NewSource(time.Now().UnixNano())
	random := rand.New(source)
	number := random.Intn(1000)
	namePrefix := fmt.Sprintf("ghci%d-", number)

	// define options for Terraform
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		VarFiles:     []string{"example.tfvars"},
		Vars: map[string]interface{}{
			"name_prefix": namePrefix,
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
