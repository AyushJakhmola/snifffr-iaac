# Define the CloudFront distribution
resource "aws_cloudfront_distribution" "alb_cache" {
  enabled             = true
  aliases = ["${local.environment}.snifffr.com"]
  web_acl_id = aws_wafv2_web_acl.cloud_front_waf.arn
  is_ipv6_enabled     = true
  
  origin {
    origin_id   = "alb"
    domain_name = module.alb.dns_name
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_ssl_protocols =["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_protocol_policy = "match-viewer"
    }
  } 
  
  # Configure SSL settings
  viewer_certificate {
    acm_certificate_arn = var.acm
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Define the default cache behavior
  default_cache_behavior {
    compress         = true
    # min_ttl                = 300
    # max_ttl                = 86400
    # default_ttl            = 3600
    allowed_methods = var.cache_config.allowed_methods
    cached_methods  = var.cache_config.cached_methods
    cache_policy_id = aws_cloudfront_cache_policy.cache_policy.id
    target_origin_id = var.cache_config.origin_id
    viewer_protocol_policy = var.cache_config.viewer_protocol_policy
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_policy.id
    # response_headers_policy_id = aws_cloudfront_response_headers_policy.headers_config.id
  }

   ordered_cache_behavior {
    compress               = true
    # min_ttl                = 0
    # max_ttl                = 0
    # default_ttl            = 0
    path_pattern     = "/arrowchat"
    allowed_methods = var.cache_config.allowed_methods
    cached_methods  = var.cache_config.cached_methods
    cache_policy_id  = var.cache_config.cache_disable_policy
    target_origin_id = var.cache_config.origin_id
    viewer_protocol_policy = var.cache_config.viewer_protocol_policy
    # response_headers_policy_id = aws_cloudfront_response_headers_policy.headers_config.id
  }

  ordered_cache_behavior {  
    compress               = true
    # min_ttl                = 300
    # max_ttl                = 86400
    # default_ttl            = 3600
    path_pattern     = "/wp-content"
    allowed_methods = var.cache_config.allowed_methods
    cached_methods  = var.cache_config.cached_methods
    cache_policy_id = aws_cloudfront_cache_policy.cache_policy.id
    target_origin_id = var.cache_config.origin_id
    viewer_protocol_policy = var.cache_config.viewer_protocol_policy
    # response_headers_policy_id = aws_cloudfront_response_headers_policy.headers_config.id
  }

    ordered_cache_behavior {
    compress               = true
    # min_ttl                = 300 
    # max_ttl                = 86400
    # default_ttl            = 3600
    path_pattern     = "/members"
    allowed_methods = var.cache_config.allowed_methods
    cached_methods  = var.cache_config.cached_methods
    cache_policy_id = aws_cloudfront_cache_policy.cache_policy.id
    target_origin_id = var.cache_config.origin_id
    viewer_protocol_policy = var.cache_config.viewer_protocol_policy
    # response_headers_policy_id = aws_cloudfront_response_headers_policy.headers_config.id
  }

  # error response 
  custom_error_response {
    error_code = 500
    error_caching_min_ttl = 420
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "headers_config" {
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

#     security_headers_config {
#     content_type_options {
#       override = true
#     }
#     frame_options {
#       frame_option = "DENY"
#       override     = true
#     }
#     referrer_policy {
#       referrer_policy = "same-origin"
#       override        = true
#     }
# }
}

resource "aws_cloudfront_cache_policy" "cache_policy" {
  name        = format("%s-%s-cache-policy", local.environment, local.name)
  default_ttl = 86400
  max_ttl     = 604800
  min_ttl     = 60
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Accept-Charset", "Authorization", "Origin", "Accept", "Access-Control-Request-Method", "Access-Control-Request-Headers", "Referer", "Host", "Accept-Language", "Accept-Datetime"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}


resource "aws_cloudfront_origin_request_policy" "origin_policy" {
  name    = format("%s-%s-origin-policy", local.environment, local.name)
  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allExcept"
    headers {
      items = ["X-Accel-Expires", "Set-Cookie", "Vary", "Expires"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}