# Define the CloudFront distribution
resource "aws_cloudfront_distribution" "alb_cache" {
  enabled = true
  aliases = ["${local.environment}.snifffr.com"]
  # web_acl_id = "arn:aws:wafv2:us-east-1:678109907733:global/webacl/CreatedByCloudFront-28e1abbe-5cf4-4c14-a05f-f0759b26dbfe/d74fec47-9deb-456a-ade3-24d103ed1be1"
  is_ipv6_enabled = true

  origin {
    origin_id   = "alb"
    domain_name = module.alb.dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_protocol_policy = "match-viewer"
    }
  }

  # Configure SSL settings
  viewer_certificate {
    acm_certificate_arn      = var.acm
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Define the default cache behavior
  default_cache_behavior {
    compress        = true
    allowed_methods = var.cache_config.allowed_methods
    cached_methods  = var.cache_config.cached_methods
    # cache_policy_id  = var.cache_config.cache_enable_policy
    cache_policy_id        = "b87e1769-f595-4ce2-97dd-d52adbf164fc"
    target_origin_id       = var.cache_config.origin_id
    viewer_protocol_policy = var.cache_config.viewer_protocol_policy
    # forwarded_values {
    #   headers = ["*"]
    #   query_string = true
    #   cookies {
    #     forward = "all"
    #   }
    # }
  }

  ordered_cache_behavior {
    compress               = true
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0
    path_pattern           = "/arrowchat"
    allowed_methods        = var.cache_config.allowed_methods
    cached_methods         = var.cache_config.cached_methods
    cache_policy_id        = var.cache_config.cache_disable_policy
    target_origin_id       = var.cache_config.origin_id
    viewer_protocol_policy = var.cache_config.viewer_protocol_policy
  }

  ordered_cache_behavior {
    compress        = true
    min_ttl         = 0
    max_ttl         = 86400
    default_ttl     = 3600
    path_pattern    = "/wp-content"
    allowed_methods = var.cache_config.allowed_methods
    cached_methods  = var.cache_config.cached_methods
    # cache_policy_id  = var.cache_config.cache_enable_policy
    target_origin_id           = var.cache_config.origin_id
    viewer_protocol_policy     = var.cache_config.viewer_protocol_policy
    response_headers_policy_id = aws_cloudfront_response_headers_policy.hide_headers.id
    forwarded_values {
      headers      = ["*"]
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    compress                   = true
    min_ttl                    = 0
    max_ttl                    = 86400
    default_ttl                = 3600
    path_pattern               = "/members"
    allowed_methods            = var.cache_config.allowed_methods
    cached_methods             = var.cache_config.cached_methods
    cache_policy_id            = var.cache_config.cache_enable_policy
    target_origin_id           = var.cache_config.origin_id
    viewer_protocol_policy     = var.cache_config.viewer_protocol_policy
    response_headers_policy_id = aws_cloudfront_response_headers_policy.hide_headers.id
  }

  # error response 
  custom_error_response {
    error_code            = 500
    error_caching_min_ttl = 420
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "hide_headers" {
  name = format("%s-%s-response-header-policy", local.environment, local.name)
  remove_headers_config {
    items {
      header = "Pragma"
    }
    items {
      header = "Link"
    }
    items {
      header = "x-powered-by"
    }
    items {
      header = "Vary"
    }
    items {
      header = "X-Redirect-By"
    }
    items {
      header = "Set-Cookie"
    }
    items {
      header = "Cache-Control"
    }
    items {
      header = "X-Pingback"
    }
    items {
      header = "Expires"
    }
    items {
      header = "X-Accel-Expires"
    }
    items {
      header = "Cache-Control"
    }
  }
}