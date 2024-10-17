# CloudFront distribution
resource "aws_cloudfront_distribution" "static_website_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.domain_name}"

  origin {
    domain_name = aws_s3_bucket_website_configuration.static_website.website_endpoint
    origin_id   = "S3-${aws_s3_bucket.static_website.bucket}"
      custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }

  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.static_website.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "CloudFront Distribution"
  }
  aliases = [var.domain_name]
}

# Route 53 record to point to CloudFront distribution
# resource "aws_route53_record" "www" {
#   zone_id = var.hosted_zone_id
#   name    = "www.${var.domain_name}"
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.static_website_distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.static_website_distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

resource "aws_route53_record" "root_domain" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.static_website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.static_website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
