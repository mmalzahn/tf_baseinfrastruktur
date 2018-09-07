locals {
  common_tags {
    responsible     = "${var.tag_responsibel}"
    tf_managed      = "1"
    tf_project      = "dca:${terraform.workspace}:${random_id.randomPart.b64_url}:${replace(var.project_name," ","")}"
    tf_project_name = "DCA_${replace(var.project_name," ","_")}_${terraform.workspace}"
    tf_environment  = "${terraform.workspace}"
    tf_created      = "${timestamp()}"
    tf_runtime      = "${var.laufzeit_tage}"
    tf_responsible  = "${var.tag_responsibel}"
    tf_configId     = "${local.projectId}"
  }

  projectId       = "${random_string.projectId.result}"
  adminInfoTopic  = "${data.dns_txt_record_set.infotopic.record}"
  resource_prefix = "tf-${random_id.randomPart.b64_url}-${replace(var.project_name,"_","")}-${terraform.workspace}-"
  workspace_key   = "env:/${terraform.workspace}/${var.backend_key}"
}

resource "random_string" "projectId" {
  length  = 10
  special = false
  upper   = false
  number  = false
}

data "dns_txt_record_set" "infotopic" {
  host = "_infotopic.${var.dns_domain}"
}

data "aws_availability_zones" "azs" {}

data "aws_route53_zone" "dca_poc_domain" {
  name = "${var.dns_domain}."
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

data "aws_acm_certificate" "cert_dev" {
  provider = "aws.usa"
  domain   = "*.dev.${var.dns_domain}"
}

data "aws_acm_certificate" "cert_base" {
  provider = "aws.usa"
  domain   = "*.${var.dns_domain}"
}

data "aws_ami" "bastionhostPackerAmi" {
  owners      = ["681337066511"]
  most_recent = true

  filter {
    name   = "tag:tf_packerid"
    values = ["bastionhost"]
  }
}

resource "random_id" "configId" {
  byte_length = 16
}

resource "random_id" "randomPart" {
  byte_length = 4
}
