package test

import (
	"crypto/tls"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func Reaching(t *testing.T) {
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "main")

	awsRegion := aws.GetRandomRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testFolder,

		Vars: map[string]interface{}{
			"region": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	lb_public_ip := terraform.Output(t, terraformOptions, "lb_public_ip")

	tlsConfig := tls.Config{}

	// http_helper.HttpGetWithRetry(t, "http://"+lb_public_ip, ' ', &tlsConfig, 200, 10, 5*time.Second)
}
