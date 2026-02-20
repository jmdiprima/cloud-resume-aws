# Package the Lambda source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../backend/lambda_function.py"
  output_path = "${path.module}/../backend/lambda_function.zip"
}

# IAM role assumed by the Lambda function
resource "aws_iam_role" "lambda_exec" {
  name = "cloud-resume-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.project_tags
}

# Least-privilege policy: only the DynamoDB operations the function needs
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "cloud-resume-lambda-dynamodb"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:UpdateItem"
      ]
      Resource = aws_dynamodb_table.visitor_count.arn
    }]
  })
}

# Allow Lambda to write CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "visitor_counter" {
  function_name = "cloud-resume-visitor-counter"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Limit concurrent executions to prevent runaway invocations
  reserved_concurrent_executions = 5

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.visitor_count.name
      ALLOWED_ORIGIN = "https://${var.domain_name}"
    }
  }

  tags = var.project_tags
}
