data "aws_route53_zone" "dca_poc_domain" {
  name = "dca-poc.de."
}

data "aws_route53_zone" "dca_internal_domain" {
  name = "dca.internal."
  private_zone = "true"
}

data "aws_availability_zones" "azs" {
  
}
