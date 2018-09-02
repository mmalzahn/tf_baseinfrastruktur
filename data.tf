locals {
  common_tags {
    responsible     = "${var.tag_responsibel}"
    tf_managed      = "1"
    tf_project      = "dca:${terraform.workspace}:base:${replace(var.project_name," ","")}"
    tf_project_name = "DCA_${replace(var.project_name," ","_")}_${terraform.workspace}"
    tf_environment  = "${terraform.workspace}"
    tf_created      = "${timestamp()}"
    tf_runtime      = "${var.laufzeit_tage}"
    tf_responsible  = "${var.tag_responsibel}"
    tf_configId     = "${random_id.configId.b64_url}"
  }

  resource_prefix = "${var.project_name}-${terraform.workspace}-"
  workspace_key   = "env:/${terraform.workspace}/${var.backend_key}"
}

data "aws_availability_zones" "azs" {}

data "aws_route53_zone" "dca_poc_domain" {
  name = "dca-poc.de."
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "random_id" "configId" {
  byte_length = 16
}

 data "aws_acm_certificate" "cert" {
   provider = "aws.usa"
   domain   = "*.dev.dca-poc.de"
 }