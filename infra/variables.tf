variable "aws_region" {
  description = "Primary AWS region for all resources"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "cloud-resume"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
  default     = "julesdiprima.com"
}

variable "resume_subdomain" {
  description = "Subdomain for the resume site"
  type        = string
  default     = "resume"
}

variable "blog_subdomain" {
  description = "Subdomain for the blog"
  type        = string
  default     = "blog"
}
