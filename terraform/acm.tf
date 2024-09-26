# ACM Certificate
resource "aws_acm_certificate" "acm" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Environment = "${var.env}-acm"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 resources to perform DNS auto validation
resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for i in aws_acm_certificate.acm.domain_validation_options : i.domain_name => {
      name   = i.resource_record_name
      record = i.resource_record_value
      type   = i.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# ACM certificate validation
resource "aws_acm_certificate_validation" "validation" {
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}