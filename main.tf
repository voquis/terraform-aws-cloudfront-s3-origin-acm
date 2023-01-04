# ---------------------------------------------------------------------------------------------------------------------
# Origin access identity, used by CloudFront to access S3 bucket
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.origin_access_identity_comment
}

# ---------------------------------------------------------------------------------------------------------------------
# Bucket policy to allow CloudFront to read from this bucket
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "this" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.this.json
}

# ---------------------------------------------------------------------------------------------------------------------
# Policy document to be used as S3 bucket policy.  Allows origin access identity to read from S3 bucket
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "this" {
  version = "2008-10-17"
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.this.iam_arn
      ]
    }
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [var.bucket_arn]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.this.iam_arn
      ]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Cloudfront distrubution to serve static content from S3 bucket.
# Optimised for single page apps where all routes (including those resulting in 404s) are forwarded to a single page.
# ACM certificate must be in US East 1 region, regardless of where S3 bucket is located.
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#viewer_certificate
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "this" {
  aliases             = var.aliases
  default_root_object = var.default_root_object
  enabled             = var.enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  # Custom Error response
  custom_error_response {
    error_code         = 404
    response_code      = var.custom_error_response_code
    response_page_path = var.custom_error_response_page_path
  }
  # Default cache behaviour
  default_cache_behavior {
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    compress               = var.compress
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    min_ttl                = var.min_ttl
    target_origin_id       = var.bucket_id
    viewer_protocol_policy = var.viewer_protocol_policy
    forwarded_values {
      query_string = var.forwarded_values_query_string
      cookies {
        forward = var.forwarded_values_cookies
      }
    }

    dynamic "function_association" {
      for_each = var.function_association == null ? [] : [var.function_association]
      content {
        event_type   = function_association.value["event_type"]
        function_arn = function_association.value["function_arn"]
      }
    }
  }

  # S3 origin definition
  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = var.bucket_id
    origin_path = var.origin_path
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }
  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
    }
  }
  # Viewer certificate
  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = var.cloudfront_default_certificate
    minimum_protocol_version       = var.minimum_protocol_version
    ssl_support_method             = var.ssl_support_method
  }
}
