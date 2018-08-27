locals {
  common_tags {
    responsible = "${var.tag_responsibel}"
    tf_managed   = "true"
    tf_project = "base:vpc"
    tf_statefile = "terraform"
    tf_environment = "${terraform.workspace}"
    tf_created = "${timestamp()}"
    tf_needuntil = "${timeadd(timestamp(), var.laufzeit_tage)}"
  }
  workspace_key = "env:/${terraform.workspace}/${var.backend_key}"
}

data "aws_availability_zones" "azs" {}

data "aws_route53_zone" "dca_poc_domain" {
  name = "dca-poc.de."
}
