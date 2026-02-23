# AGENTS.md — Codex Agent Instructions

## Project Overview
This is the AWS Cloud Resume Challenge project for julesdiprima.com.
It deploys a static HTML/CSS resume with a serverless visitor counter
using S3, CloudFront, API Gateway, Lambda (Python 3.12), and DynamoDB.
All infrastructure is managed via Terraform. CI/CD uses GitHub Actions
with OIDC federation (no static AWS keys).

## Repository Structure
```
cloud-resume-aws/
├── frontend/          # Static website (HTML, CSS, JS)
│   ├── index.html
│   ├── css/style.css
│   ├── js/visitor-counter.js
│   ├── error.html
│   └── robots.txt
├── backend/
│   ├── lambda/        # Python Lambda function
│   │   ├── visitor_counter.py
│   │   └── requirements.txt
│   └── tests/         # pytest + moto tests
│       ├── conftest.py
│       └── test_visitor_counter.py
├── infra/             # Terraform IaC
│   ├── main.tf
│   ├── waf.tf
│   ├── monitoring.tf
│   ├── iam.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── backend.tf
│   └── terraform.tfvars.example
├── blog/              # Hugo blog
├── .github/workflows/ # CI/CD pipelines
└── AGENTS.md          # This file
```

## Coding Standards
- Python: Follow PEP 8, use type hints, include docstrings on all public functions
- Terraform: Use consistent naming with var.project_name prefix, tag every resource,
  add comments explaining security decisions
- JavaScript: Use async/await, JSDoc comments, no external dependencies
- All code must be production-quality, not tutorial-grade

## Security Requirements (NON-NEGOTIABLE)
- NEVER use wildcard (*) CORS origins — always use the specific domain
- NEVER create IAM policies with wildcard resources unless absolutely required
- NEVER hardcode secrets, credentials, or sensitive values
- All S3 buckets MUST block public access
- All encryption MUST be enabled (at rest and in transit)
- Lambda environment variables MUST be validated at startup
- Error responses MUST NOT leak internal details

## How to Test
- Python: `python -m pytest backend/tests/ -v` from repo root
- Terraform: `cd infra && terraform validate && terraform plan`
- IaC Security: `tfsec infra/` and `checkov -d infra/`

## How to Build
- Frontend: Static files, no build step. Deploy via `aws s3 sync frontend/ s3://<bucket>`
- Backend: `cd backend/lambda && zip -r function.zip .`
- Blog: `cd blog && hugo --minify`
- Infrastructure: `cd infra && terraform init && terraform apply`

## Key Variables
- Domain: julesdiprima.com
- Resume subdomain: resume
- Blog subdomain: blog
- AWS Region: us-east-1
- Project name prefix: cloud-resume
- Environment: prod
- GitHub repo: jmdiprima/cloud-resume-aws
```
