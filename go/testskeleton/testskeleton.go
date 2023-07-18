package testskeleton

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	tfjson "github.com/hashicorp/terraform-json"
	"github.com/stretchr/testify/assert"
	"golang.org/x/exp/maps"
)

// Sometimes there is a need to execute custom function to check something,
// so then in assert expression we need to provide function, which results is compared to true
type CheckFunction func(t *testing.T, outputValue string) bool

// Structure used to assert each output value
// by comparing it to expected value using defined operation.
type AssertExpression struct {
	OutputName    string
	Operation     AssertOperation
	ExpectedValue interface{}
	Message       string
	Check         CheckFunction
	TestedValue   string
}

// Enum for operations in assert expressions
type AssertOperation int64

const (
	NotEmpty AssertOperation = iota
	Empty
	Equal
	NotFound
	ListLengthEqual
	StartsWith
	CheckFunctionWithOutput
	CheckFunctionWithValue
	EqualToValue
	ErrorContains
)

// Structure used to verify if there are changes in resources after adding additional
// Terraform code or after changing values of some variables
type ChangedResource struct {
	Name   string
	Action tfjson.Action
}
type AdditionalChangesAfterDeployment struct {
	AdditionalVarsValues map[string]interface{}
	UseVarFiles          []string
	FileNameWithTfCode   string
	ChangedResources     []ChangedResource
}

// Structure used for Azure deployments - contains randomly generated resource names.
type AzureRandomNames struct {
	NamePrefix         string
	ResourceGroupName  string
	StorageAccountName string
}

// Function that generates and return a set of random Azure resource names.
// Randomization is based on UUID.
func GenerateAzureRandomNames() AzureRandomNames {
	id := uuid.New().String()
	idSliced := strings.Split(id, "-")

	prefixId := idSliced[2]
	gid := idSliced[0:2]
	storageId := idSliced[3:5]

	names := AzureRandomNames{
		NamePrefix:         fmt.Sprintf("ghci%s-", prefixId),
		ResourceGroupName:  strings.Join(gid, ""),
		StorageAccountName: fmt.Sprintf("ghci%s", strings.Join(storageId, "")),
		// StorageAccountName: strings.Join(storageId, ""),
	}

	return names
}

// Function running only only code validation.
func ValidateCode(t *testing.T, terraformOptions *terraform.Options) *terraform.Options {
	if terraformOptions == nil {
		terraformOptions = terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: ".",
			Logger:       logger.Default,
			Lock:         true,
			Upgrade:      true,
		})
	}

	terraform.InitAndValidate(t, terraformOptions)

	return terraformOptions
}

// Function is responsible for deployment of the infrastructure,
// verify assert expressions and destroy infrastructure
func DeployInfraCheckOutputs(t *testing.T, terraformOptions *terraform.Options, assertList []AssertExpression) *terraform.Options {
	return GenericDeployInfraAndVerifyAssertChanges(t, terraformOptions, assertList, false, nil, true)
}

// Function is responsible for deployment of the infrastructure, verify assert expressions,
// verify if there are no changes in plan after deployment and destroy infrastructure
func DeployInfraCheckOutputsVerifyChanges(t *testing.T, terraformOptions *terraform.Options, assertList []AssertExpression) *terraform.Options {
	return GenericDeployInfraAndVerifyAssertChanges(t, terraformOptions, assertList, true, nil, true)
}

// Function is responsible for deployment of the infrastructure, verify assert expressions,
// verify if there are no changes in plan after deployment and destroy infrastructure
func DeployInfraCheckOutputsVerifyChangesDeployChanges(t *testing.T, terraformOptions *terraform.Options,
	assertList []AssertExpression, additionalChangesAfterDeployment []AdditionalChangesAfterDeployment) *terraform.Options {
	return GenericDeployInfraAndVerifyAssertChanges(t, terraformOptions, assertList, true, additionalChangesAfterDeployment, true)
}

// Function is responsible only for deployment of the infrastructure,
// no verification of assert expressions and no destroyment of the infrastructure
func DeployInfraNoCheckOutputsNoDestroy(t *testing.T, terraformOptions *terraform.Options) *terraform.Options {
	return GenericDeployInfraAndVerifyAssertChanges(t, terraformOptions, nil, false, nil, false)
}

// Generic deployment function used in wrapper functions above
//   - terraformOptions - Terraform options required to execute tests in Terratest
//   - assertList - list of assert expression
//   - checkNoChanges - if true, after deployment check if there are no changes planed
//   - additionalChangesAfterDeployment - if not empty, then it contains list of additional variables values and resources in external file
//     to plan and deploy in order to verify if all expected changes are being provisioned, nothing more or less
//   - destroyInfraAtEnd - if true, destroy infrastructure at the end of test
func GenericDeployInfraAndVerifyAssertChanges(t *testing.T,
	terraformOptions *terraform.Options,
	assertList []AssertExpression,
	checkNoChanges bool,
	additionalChangesAfterDeployment []AdditionalChangesAfterDeployment,
	destroyInfraAtEnd bool) *terraform.Options {
	// If no Terraform options were provided, use default one
	if terraformOptions == nil {
		terraformOptions = terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: ".",
			Logger:       logger.Default,
			Lock:         true,
			Upgrade:      true,
		})
	}

	// Destroy infrastructure, even if any assert expression fails
	if destroyInfraAtEnd {
		destroyFunc := func() {
			terraform.Destroy(t, terraformOptions)
		}
		defer destroyFunc()
	}

	// Terraform initalization and apply with auto-approve
	terraform.InitAndApply(t, terraformOptions)

	// Verify outputs and compare to expected results
	if assertList != nil && len(assertList) > 0 {
		AssertOutputs(t, terraformOptions, assertList)
	}

	// Check if there are no changes planed after deployment (if checkNoChanges is true)
	if checkNoChanges {
		terraformOptions.PlanFilePath = "test.plan"
		planStructure := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
		for _, v := range planStructure.ResourceChangesMap {
			checkResourceChange(t, v, nil)
		}
	}

	// If there is passed structure with additional changes deployed after,
	// then verify if changes in infrastructure are the same as expected
	if additionalChangesAfterDeployment != nil && len(additionalChangesAfterDeployment) > 0 {
		for _, additionalChangeAfterDeployment := range additionalChangesAfterDeployment {
			planAndDeployAdditionalChangesAfterDeployment(t, terraformOptions, &additionalChangeAfterDeployment)
		}
	}

	return terraformOptions
}

// Function is comparing every provided output in expressions lists
// and checks value using expression defined in the list
func AssertOutputs(t *testing.T, terraformOptions *terraform.Options, assertList []AssertExpression) {
	for _, assertExpression := range assertList {
		switch assertExpression.Operation {
		case NotEmpty:
			outputValue := terraform.Output(t, terraformOptions, assertExpression.OutputName)
			assert.NotEmpty(t, outputValue, assertExpression.Message)
		case Empty:
			outputValue := terraform.Output(t, terraformOptions, assertExpression.OutputName)
			assert.Empty(t, outputValue, assertExpression.Message)
		case Equal:
			outputValue := terraform.Output(t, terraformOptions, assertExpression.OutputName)
			assert.Equal(t, assertExpression.ExpectedValue, outputValue, assertExpression.Message)
		case NotFound:
			_, err := terraform.OutputE(t, terraformOptions, assertExpression.OutputName)
			assert.ErrorContains(t, err,
				fmt.Sprintf("Output \"%v\" not found", assertExpression.OutputName),
				assertExpression.Message)
		case ListLengthEqual:
			outputValue := terraform.OutputList(t, terraformOptions, assertExpression.OutputName)
			assert.Equal(t, assertExpression.ExpectedValue, len(outputValue), assertExpression.Message)
		case StartsWith:
			outputValue := terraform.Output(t, terraformOptions, assertExpression.OutputName)
			assert.True(t, strings.HasPrefix(outputValue,
				fmt.Sprintf("%v", assertExpression.ExpectedValue)),
				assertExpression.Message)
		case CheckFunctionWithOutput:
			outputValue := terraform.Output(t, terraformOptions, assertExpression.OutputName)
			assert.True(t, assertExpression.Check(t, outputValue), assertExpression.Message)
		case CheckFunctionWithValue:
			assert.True(t, assertExpression.Check(t, assertExpression.TestedValue), assertExpression.Message)
		case EqualToValue:
			assert.Equal(t, assertExpression.TestedValue, assertExpression.ExpectedValue)
		default:
			tLogger := logger.Logger{}
			tLogger.Logf(t, "Unknown operation used in assert expressions list")
			t.Fail()
		}
	}
}

// Function is checking if in ResourceChangesMap from PlanStruct
// there are planned any resources to be added, deleted or changed
func checkResourceChange(t *testing.T, v *tfjson.ResourceChange, changedResources []ChangedResource) {
	// Simple structure used to story 2 information:
	// - updated - if anything is going to change
	// - updateType - what kind of change is going to be done (create, delete, update)
	var hasUpdate struct {
		updated    bool
		updateType tfjson.Action
	}

	for _, action := range v.Change.Actions {
		if action == tfjson.ActionDelete || action == tfjson.ActionCreate || action == tfjson.ActionUpdate {
			hasUpdate.updated = true
			hasUpdate.updateType = action
		}
	}

	// If we are not expecting any change in resource, check if nothing was planned to change
	if changedResources == nil {
		assert.False(t, hasUpdate.updated, "Resource %v is about to be %sd, but it shouldn't", v.Address, hasUpdate.updateType)
	} else {
		// If we are expecting changes, check if all expected changes are planned to happen
		asExpected := false
		for _, changedResource := range changedResources {
			if changedResource.Name == v.Address && changedResource.Action == hasUpdate.updateType {
				asExpected = true
			}
		}
		// Moreover check if any unexpected change is planned to happen
		if asExpected == false && len(v.Change.Actions) == 1 && v.Change.Actions[0] == tfjson.ActionNoop {
			asExpected = true
		}
		assert.True(t, asExpected, "Resource %v is about to be %vd, but it shouldn't", v.Address, hasUpdate.updateType)
	}
}

// Function is doing Terraform plan after initial deployment and providing changes in variables values and resources
func planAndDeployAdditionalChangesAfterDeployment(t *testing.T, terraformOptions *terraform.Options, additionalChangesAfterDeployment *AdditionalChangesAfterDeployment) {
	// If var files defined, use them
	if additionalChangesAfterDeployment.UseVarFiles != nil && len(additionalChangesAfterDeployment.UseVarFiles) > 0 {
		terraformOptions.VarFiles = additionalChangesAfterDeployment.UseVarFiles
	}

	// Merge original variables values with additional ones
	maps.Copy(terraformOptions.Vars, additionalChangesAfterDeployment.AdditionalVarsValues)

	// If in structure AdditionalChangesAfterDeployment filename was provided (it's not empty), then name provided file
	if additionalChangesAfterDeployment.FileNameWithTfCode != "" {
		// Rename provided file by adding .tf extension in order to add additional resources defined in file
		renameFileFunc := func(orgFileName string, newFileName string) {
			err := os.Rename(orgFileName, newFileName)
			if err != nil {
				t.Logf("Error while preparing additional file with code to deploy: %v", err)
			}
		}
		additionalFileNameWithTfExtension := additionalChangesAfterDeployment.FileNameWithTfCode + ".tf"
		renameFileFunc(additionalChangesAfterDeployment.FileNameWithTfCode, additionalFileNameWithTfExtension)

		// Always restore original file name
		defer renameFileFunc(additionalFileNameWithTfExtension, additionalChangesAfterDeployment.FileNameWithTfCode)
	}

	// Prepare plan and check changes by comparing them to expected one
	terraformOptions.PlanFilePath = "test.plan"
	planStructure := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	for _, v := range planStructure.ResourceChangesMap {
		checkResourceChange(t, v, additionalChangesAfterDeployment.ChangedResources)
	}

	// Deploy changes, if all asserts passed after plan
	if !t.Failed() {
		terraform.Apply(t, terraformOptions)
	}
}

// Functions is response for planning deployment,
// verify errors expressions (no changes are deployed)
func PlanInfraCheckErrors(t *testing.T, terraformOptions *terraform.Options,
	assertList []AssertExpression, noErrorsMessage string) *terraform.Options {
	// If no Terraform options were provided, use default one
	if terraformOptions == nil {
		terraformOptions = terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: ".",
			Logger:       logger.Default,
			Lock:         true,
			Upgrade:      true,
		})
	}

	// Terraform initalization and plan
	if _, err := terraform.InitAndPlanE(t, terraformOptions); err != nil {
		if len(assertList) > 0 {
			// Verify errors and compare to expected results
			assert.Error(t, err)
			AssertErrors(t, err, assertList)
		} else {
			t.Error(noErrorsMessage)
		}
	} else {
		// Fail test, if errors were expected
		if len(assertList) > 0 {
			t.Error(noErrorsMessage)
		}
	}

	return terraformOptions
}

// Function is comparing every provided error in expressions lists
// and checks value using expression defined in the list
func AssertErrors(t *testing.T, err error, assertList []AssertExpression) {
	for _, assertExpression := range assertList {
		switch assertExpression.Operation {
		case ErrorContains:
			assert.ErrorContains(t, err,
				fmt.Sprintf("%v", assertExpression.ExpectedValue),
				assertExpression.Message)
		default:
			tLogger := logger.Logger{}
			tLogger.Logf(t, "Unknown operation used in assert expressions list")
			t.Fail()
		}
	}
}
