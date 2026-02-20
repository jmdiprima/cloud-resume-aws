# ── S3 Bucket ──────────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "frontend" {
  bucket        = var.s3_bucket_name
  force_destroy = true
  tags          = var.project_tags
}

# Block all public access — CloudFront accesses the bucket via OAC only
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── CloudFront Origin Access Control ───────────────────────────────────────────
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "cloud-resume-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ── S3 Bucket Policy — allow only the CloudFront distribution via OAC ──────────
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontServicePrincipal"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.frontend.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.resume.arn
        }
      }
    }]
  })
}

# ── ACM Certificate (must be in us-east-1 for CloudFront) ─────────────────────
# TODO: Add DNS validation records in Route 53 or your DNS provider
resource "aws_acm_certificate" "resume" {
  provider                  = aws.us_east_1
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.project_tags
}

# ── CloudFront Response Headers Policy (security headers) ─────────────────────
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "cloud-resume-security-headers"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }

  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "camera=(), microphone=(), geolocation=()"
      override = true
    }

    items {
      header   = "Content-Security-Policy"
      value    = "default-src 'self'; script-src 'self'; connect-src https://*.execute-api.us-east-2.amazonaws.com; style-src 'self' 'unsafe-inline'; img-src 'self' data:;"
      override = true
    }
  }
}

# ── CloudFront Distribution ────────────────────────────────────────────────────
resource "aws_cloudfront_distribution" "resume" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = [var.domain_name, "www.${var.domain_name}"]

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-${var.s3_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "S3-${var.s3_bucket_name}"
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # SPA-style: route 404s back to index.html
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.resume.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.project_tags
}
