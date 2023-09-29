package vnet

import (
	"encoding/json"
	"os"
	"testing"

	"github.com/PaloAltoNetworks/terraform-modules-vmseries-tests-skeleton/pkg/testskeleton"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

const testModulePath = "../../tests/modules/vnet"

func TestValidate(t *testing.T) {
	testskeleton.ValidateCode(t, nil)
}

func CreateTerraformOptions(t *testing.T) *terraform.Options {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:         testModulePath,
		VarFiles:             []string{"plan.tfvars"},
		Logger:               logger.Default,
		Lock:                 true,
		Upgrade:              true,
		SetVarsAfterVarFiles: true,
		PlanFilePath:         "plan.tfplan",
	})

	return terraformOptions
}

func TestSetup(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)

	tfplan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	standardPlan := make(map[string][]string)
	standardPlan["plannedValues"] = make([]string, len(tfplan.ResourcePlannedValuesMap))
	standardPlan["changedValues"] = make([]string, len(tfplan.ResourcePlannedValuesMap))

	i := 0
	for k := range tfplan.ResourcePlannedValuesMap {
		standardPlan["plannedValues"][i] = k
		i++
	}
	i = 0
	for k := range tfplan.ResourceChangesMap {
		standardPlan["changedValues"][i] = k
		i++
	}
	standardPlanJSON, _ := json.MarshalIndent(standardPlan, "", "    ")
	println()
	println(string(standardPlanJSON))
	println()
}

func TestPlan(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)

	tfplan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	standardPlanJSON, _ := os.ReadFile(testModulePath + "/standard_plan.json")
	var standardPlan map[string][]string
	json.Unmarshal(standardPlanJSON, &standardPlan)

	for _, planned := range standardPlan["plannedValues"] {
		terraform.AssertPlannedValuesMapKeyExists(t, tfplan, planned)
	}
	for _, changed := range standardPlan["changedValues"] {
		terraform.AssertResourceChangesMapKeyExists(t, tfplan, changed)
	}

}
