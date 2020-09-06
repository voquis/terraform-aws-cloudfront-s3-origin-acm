CloudFront distribution with S3 Origin and ACM Certificate
===
Terraform 0.12+ module to create a CloudFront distribution from an S3 bucket with a custom ACM certificate.
Note that the ACM certificate must exist in the US East 1 region, regardless of whether a certificate for the same domain name exists in another region and also regardless of where the S3 origin is.

This module assumes the entire S3 bucket will be used for serving content.
This module is useful for creating single page apps (SPAs) in JavaScript where all routes are forwarded to a single page. In this case, both the `default_root_object` and the 404 `custom_error_response_page_path` will refer to `index.html` for example.

To make changes to a distribution once deployed, update the origin path.
For example, a version 1.0 project could be placed in a `v1.0` directory, and the next version of the project placed in `v1.1`.
Updating the `origin_path` from `v1.0` to `v1.1` would invalidate the cache and redeploy the new distribution.

# Exmaples
```terraform
module "cloudfront" {
  source      = "voquis/cloudfront-s3-origin-acm/aws"
  version     = "0.0.1"
  bucket_id   = aws_route53_zone.example_com.id
  domain_name = "example.com"
}
```
