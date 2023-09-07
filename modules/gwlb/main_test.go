package bootstrap

import (
	"testing"

	"github.com/PaloAltoNetworks/terraform-modules-vmseries-tests-skeleton/pkg/testskeleton"
)

func TestValidate(t *testing.T) {
	testskeleton.ValidateCode(t, nil)
}
