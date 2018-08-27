locals {
  common_tags {
    responsible    = "${var.tag_responsibel}"
    tf_managed     = "true"
    tf_project     = "dca:${terraform.workspace}:base:vpc"
    tf_statefile   = "${local.workspace_key}"
    tf_environment = "${terraform.workspace}"
    tf_created     = "${timestamp()}"
    tf_runtime     = "${var.laufzeit_tage}"
  }

  workspace_key = "env:/${terraform.workspace}/${var.backend_key}"
}

data "aws_availability_zones" "azs" {}

data "aws_route53_zone" "dca_poc_domain" {
  name = "dca-poc.de."
}
