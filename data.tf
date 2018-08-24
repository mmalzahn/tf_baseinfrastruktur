locals {
  common_tags {
    terraform   = "true"
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    tf_project = "base:vpc"
    tf_statefile = "terraform"
    tf_environment = "${terraform.workspace}"
  }
  workspace_key = "env:/${terraform.workspace}/selfinfra.state"
}
