terraform {
  backend "s3" {
    bucket         = "cloud-resume-tfstate-jmdiprima"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "cloud-resume-tfstate-lock"
    encrypt        = true
  }
}
