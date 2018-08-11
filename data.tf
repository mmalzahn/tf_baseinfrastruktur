data "aws_route53_zone" "dca_poc_domain" {
  name = "dca-poc.de."
}

data "aws_availability_zones" "azs" {
  
}
