variable "domain_name" {
  description = "The domain name for the resume site."
  type        = string
  default     = "julesdiprima.com"
}

variable "aws_region" {
  description = "Primary AWS region for Lambda, DynamoDB, API Gateway, and S3."
  type        = string
  default     = "us-east-2"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket that hosts the frontend static files."
  type        = string
  default     = "cloud-resume-julesdiprima"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table that stores the visitor counter."
  type        = string
  default     = "cloud-resume-visitor-count"
}

variable "project_tags" {
  description = "Tags applied to all taggable resources."
  type        = map(string)
  default = {
    Project   = "cloud-resume-challenge"
    ManagedBy = "terraform"
  }
}
