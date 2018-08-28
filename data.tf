locals {
  common_tags {
    responsible     = "${var.tag_responsibel}"
    tf_managed      = "1"
    tf_project      = "dca:${terraform.workspace}:base"
    tf_project_name = "PR_${replace(var.project_name," ","_")}"
    tf_statefile    = "${local.workspace_key}"
    tf_environment  = "${terraform.workspace}"
    tf_created      = "${timestamp()}"
    tf_runtime      = "${var.laufzeit_tage}"
    tf_responsible  = "${var.tag_responsibel}"
  }

  workspace_key = "env:/${terraform.workspace}/${var.backend_key}"
}

data "aws_availability_zones" "azs" {}

data "aws_route53_zone" "dca_poc_domain" {
  name = "dca-poc.de."
}
