CloudFront distribution with S3 Origin and ACM Certificate
===
Terraform 0.12+ module to create a CloudFront distribution from an S3 bucket with a custom ACM certificate.
Note that the ACM certificate must exist in the US East 1 region, regardless of whether a certificate for the same domain name exists in another region and also regardless of where the S3 origin is.
See the [ACM with DNS validation module](https://registry.terraform.io/modules/voquis/acm-dns-validation/aws) for creating the certificate in a different region.

This module assumes the entire S3 bucket will be used for serving content, see the [S3 encrypted module](https://registry.terraform.io/modules/voquis/s3-encrypted/aws/) for creating a bucket.
This module is useful for creating single page apps (SPAs) in JavaScript where all routes are forwarded to a single page. In this case, both the `default_root_object` and the 404 `custom_error_response_page_path` will refer to `index.html` for example.

For pages created with a static site generator, the optional `function_association` object variable may be provided, to associate a Cloudfront Function with the default cache, e.g. to append `/index.html` to all requests.

To make changes to a distribution once deployed, update the origin path.
For example, a version 1.0 project could be placed in a `/v1.0` directory, and the next version of the project placed in `/v1.1`.
Updating the `origin_path` from `/v1.0` to `/v1.1` would invalidate the cache and redeploy the new distribution.

To avoid using an ACM certificate and use the default cloudfront certificate, set `cloudfront_default_certificate` to `true` and do not provide `alias` or `acm_certificate_arn`.

# Examples
## Cloudfront distribution with custom ACM certificates
```terraform
# Default provider
provider "aws" {
  version = "3.4.0"
  region  = "eu-west-2"
}

# Aliased provider in US East 1, needed for ACM certificate
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

# Create S3 bucket
module "s3" {
  source  = "voquis/s3-encrypted/aws"
  version = "0.0.4"
  bucket  = "my-super-unique-bucket-name"
}

# Hosted zone
resource "aws_route53_zone" "this" {
  name          = "example_com"
  force_destroy = false
}

# Create certificate
module "acm" {
  source  = "voquis/acm-dns-validation/aws"
  version = "0.0.4"
  providers = {
    aws = aws.useast1
  }
  zone_id     = aws_route53_zone.this.id
  domain_name = "*.example.com"
}

# Main cloudfront distribution with S3 origin
module "cloudfront" {
  source                      = "voquis/cloudfront-s3-origin-acm/aws"
  version                     = "0.0.5"
  bucket_id                   = module.s3.s3_bucket.id
  bucket_arn                  = module.s3.s3_bucket.arn
  bucket_regional_domain_name = module.s3.s3_bucket.bucket_regional_domain_name
  aliases                     = ["my.example.com"]
  acm_certificate_arn         = module.acm.acm_certificate.arn
  origin_path                 = "/v1"
}

# Route 53 record for cloudfront alias
resource "aws_route53_record" "my" {
  name    = "my"
  type    = "A"
  zone_id = aws_route53_zone.this.zone_id
  alias {
    name                   = module.cloudfront.cloudfront_distribution.domain_name
    zone_id                = module.cloudfront.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

```
## Cloudfront distribution with default viewer certificates
```terraform
# Default provider
provider "aws" {
  version = "3.4.0"
  region  = "eu-west-2"
}

# Create S3 bucket
module "s3" {
  source  = "voquis/s3-encrypted/aws"
  version = "0.0.4"
  bucket  = "my-super-unique-bucket-name"
}

# Main cloudfront distribution with S3 origin with optional ACM certification and optional alias
module "cloudfront" {
  source                         = "voquis/cloudfront-s3-origin-acm/aws"
  version                        = "0.0.5"
  bucket_id                      = module.s3.s3_bucket.id
  bucket_arn                     = module.s3.s3_bucket.arn
  bucket_regional_domain_name    = module.s3.s3_bucket.bucket_regional_domain_name
  origin_path                    = "/examplefolder"
  cloudfront_default_certificate = true
}
```
