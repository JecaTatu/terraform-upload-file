package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestS3(t *testing.T) {
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

	bucket_name := terraform.Output(t, terraformOptions, "bucket_name")
	file1_name := terraform.Output(t, terraformOptions, "file1_name")
	file2_name := terraform.Output(t, terraformOptions, "file2_name")

	file1_content := aws.GetS3ObjectContents(t, awsRegion, bucket_name, file1_name)
	file2_content := aws.GetS3ObjectContents(t, awsRegion, bucket_name, file2_name)

	aws.AssertS3BucketExists(t, awsRegion, bucket_name)
	assert.NotNil(t, file1_content)
	assert.NotNil(t, file2_content)

}
