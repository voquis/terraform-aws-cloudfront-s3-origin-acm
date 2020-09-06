output "cloudfront_origin_access_identity" {
  value = aws_cloudfront_origin_access_identity.this
}

output "s3_bucket_policy" {
  value = aws_s3_bucket_policy.this
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.this
}
