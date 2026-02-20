# Terraform remote state backend — S3 + DynamoDB locking
#
# IMPORTANT: The S3 bucket and DynamoDB lock table must be created BEFORE
# running `terraform init`. Run these AWS CLI commands once:
#
#   aws s3api create-bucket \
#     --bucket cloud-resume-tfstate-julesdiprima \
#     --region us-east-2 \
#     --create-bucket-configuration LocationConstraint=us-east-2
#
#   aws s3api put-bucket-versioning \
#     --bucket cloud-resume-tfstate-julesdiprima \
#     --versioning-configuration Status=Enabled
#
#   aws s3api put-bucket-encryption \
#     --bucket cloud-resume-tfstate-julesdiprima \
#     --server-side-encryption-configuration \
#       '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'
#
#   aws s3api put-public-access-block \
#     --bucket cloud-resume-tfstate-julesdiprima \
#     --public-access-block-configuration \
#       BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
#
#   aws dynamodb create-table \
#     --table-name terraform-locks \
#     --attribute-definitions AttributeName=LockID,AttributeType=S \
#     --key-schema AttributeName=LockID,KeyType=HASH \
#     --billing-mode PAY_PER_REQUEST \
#     --region us-east-2

terraform {
  backend "s3" {
    bucket         = "cloud-resume-tfstate-julesdiprima"
    key            = "cloud-resume/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
