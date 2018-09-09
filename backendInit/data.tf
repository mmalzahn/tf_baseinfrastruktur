locals {
  common_tags {
    responsible     = "${var.tag_responsibel}"
    tf_managed      = "1"
    tf_project      = "dca:${terraform.workspace}:${random_string.rand5.result}:${replace(var.project_name," ","")}"
    tf_project_name = "DCA_${replace(var.project_name," ","_")}_${terraform.workspace}"
    tf_environment  = "${terraform.workspace}"
    tf_created      = "${timestamp()}"
    tf_runtime      = "${var.laufzeit_tage}"
    tf_responsible  = "${var.tag_responsibel}"
  }
}

resource "random_string" "userstring" {
  length  = 16
  special = false
  upper   = false
  number  = false
}
resource "random_string" "rand5" {
  length  = 5
  special = false
  upper   = false
  number  = false
}