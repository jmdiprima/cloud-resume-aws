data "aws_caller_identity" "current" {}

# ── GitHub OIDC Provider ───────────────────────────────────────────────────────
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# ── IAM Role: Frontend CI/CD ───────────────────────────────────────────────────
resource "aws_iam_role" "github_actions_frontend" {
  name = "github-actions-frontend"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:jmdiprima/cloud-resume-aws:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = var.project_tags
}

resource "aws_iam_role_policy" "github_actions_frontend" {
  name = "github-actions-frontend-policy"
  role = aws_iam_role.github_actions_frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.frontend.arn
      },
      {
        Effect   = "Allow"
        Action   = "cloudfront:CreateInvalidation"
        Resource = aws_cloudfront_distribution.resume.arn
      }
    ]
  })
}

# ── IAM Role: Backend CI/CD ────────────────────────────────────────────────────
resource "aws_iam_role" "github_actions_backend" {
  name = "github-actions-backend"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:jmdiprima/cloud-resume-aws:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = var.project_tags
}

# NOTE: These permissions are broader than strictly necessary to support Terraform
# plan/apply for the full infra stack. They could be narrowed further in production
# by scoping to specific resource ARNs and removing any actions not needed.
resource "aws_iam_role_policy" "github_actions_backend" {
  name = "github-actions-backend-policy"
  role = aws_iam_role.github_actions_backend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:*"
        Resource = aws_lambda_function.visitor_counter.arn
      },
      {
        Effect   = "Allow"
        Action   = "dynamodb:*"
        Resource = aws_dynamodb_table.visitor_count.arn
      },
      {
        Effect   = "Allow"
        Action   = "apigateway:*"
        Resource = "arn:aws:apigateway:${var.aws_region}::*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy"
        ]
        Resource = [
          aws_iam_role.lambda_exec.arn,
          aws_iam_role.github_actions_frontend.arn,
          aws_iam_role.github_actions_backend.arn
        ]
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::cloud-resume-tfstate-julesdiprima",
          "arn:aws:s3:::cloud-resume-tfstate-julesdiprima/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/terraform-locks"
      },
      {
        Effect   = "Allow"
        Action   = "logs:*"
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })
}
