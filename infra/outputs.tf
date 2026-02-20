output "api_endpoint" {
  description = "API Gateway invoke URL for the visitor counter."
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/visitors"
}

output "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.resume.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (used for cache invalidations)."
  value       = aws_cloudfront_distribution.resume.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the frontend."
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_iam_role_arn" {
  description = "ARN of the GitHub Actions IAM role for frontend deployments."
  value       = aws_iam_role.github_actions_frontend.arn
}

output "backend_iam_role_arn" {
  description = "ARN of the GitHub Actions IAM role for backend/infra deployments."
  value       = aws_iam_role.github_actions_backend.arn
}
