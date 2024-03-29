# ---------------------------------------------------------------------------------------------------------------------
# Required variables
# ---------------------------------------------------------------------------------------------------------------------

variable "bucket_id" {
  description = "S3 bucket id, that will be used to serve content for the distribution"
  type        = string
}

variable "bucket_arn" {
  description = "S3 bucket ARN, that will be used to serve content for the distribution"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name, that will be used to serve content for the distribution"
  type        = string
}


# ---------------------------------------------------------------------------------------------------------------------
# Optional variables
# ---------------------------------------------------------------------------------------------------------------------

# Origin access identity variables
variable "origin_access_identity_comment" {
  type    = string
  default = null
}

# Main cloudfront settings
variable "aliases" {
  description = "List of CNAMEs to use as aliases for the Cloudfront domain name"
  type        = list(string)
  default     = null
}

variable "default_root_object" {
  description = "The file to serve when no path is specified"
  type        = string
  default     = "index.html"
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "price_class" {
  description = "Price Class"
  type        = string
  default     = "PriceClass_100"
}

variable "retain_on_delete" {
  description = "Whether the deployment should be disabled instead of deleted"
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "Whether Terraform should wait for the deployment before considering the resources created"
  type        = bool
  default     = true
}

# Custom error response variables
variable "custom_error_response_code" {
  description = "The HTTP status code to return when an unknown path is requested"
  type        = number
  default     = 200
}

variable "custom_error_response_page_path" {
  description = "The file to serve when an unknown path is requested"
  type        = string
  default     = "/index.html"
}

# Default cache behavior variables
variable "allowed_methods" {
  description = "List of HTTP method the default cache will allow"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "List of HTTP method the default cache will cache"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "compress" {
  description = "Whether or not compression is enabled when serving content"
  type        = bool
  default     = true
}

variable "default_ttl" {
  description = "Default time to live (TTL) for cache"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum time to live (TTL) for cache"
  type        = number
  default     = 86400
}

variable "min_ttl" {
  description = "Minimum time to live (TTL) for cache"
  type        = number
  default     = 0
}

variable "viewer_protocol_policy" {
  description = "How to handle HTTP and HTTPS"
  type        = string
  default     = "redirect-to-https"
}

variable "forwarded_values_query_string" {
  description = "Whether query string should be forwarded to cache"
  type        = bool
  default     = false
}

variable "forwarded_values_cookies" {
  description = "The cookies that should be forwarded to cache"
  type        = string
  default     = "none"
}

variable "function_association" {
  description = "Optional Cloudfront Function association for request/response events"
  type = object({
    event_type   = string
    function_arn = string
  })
  default = null
}

# Origin variables
variable "origin_path" {
  description = "The parent path within the S3 bucket from which to serve content.  Do not use /, this is implied.  Useful for updating the distribution with a new version by using directories for versioning instead of invalidation requests"
  type        = string
  default     = null
}

# Restriction variables
variable "geo_restriction_type" {
  description = "The type of geographic restriction to apply"
  type        = string
  default     = "none"
}

# Viewer certificate variables
variable "acm_certificate_arn" {
  description = "ACM Certificate ARN, note certificate must be in US East 1"
  type        = string
  default     = null
}

variable "cloudfront_default_certificate" {
  description = "Whether to use a cloudfront issued certificate instead of custom acm certificate"
  type        = string
  default     = false
}

variable "minimum_protocol_version" {
  description = "The Minimum TLS version to support"
  type        = string
  default     = "TLSv1.2_2019"
}

variable "ssl_support_method" {
  description = "The SSL method to support"
  type        = string
  default     = "sni-only"
}
