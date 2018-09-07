resource "local_file" "bastionInstallFile" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.template_file.bastionhostUserdata.rendered}"
  filename   = "${path.module}/debug/${terraform.workspace}/bastion_userdata.txt"
  depends_on = ["aws_instance.bastionhost"]
}
resource "local_file" "iamPolicyS3" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.template_file.iampolicy_s3.rendered}"
  filename   = "${path.module}/debug/${terraform.workspace}/iampolicy_s3.txt"
  depends_on = ["aws_instance.bastionhost"]
}
resource "local_file" "iamPolicySns" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.template_file.iampolicy_sns.rendered}"
  filename   = "${path.module}/debug/${terraform.workspace}/iampolicy_sns.txt"
  depends_on = ["aws_instance.bastionhost"]
}
resource "local_file" "randomConfigId" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${random_id.configId.b64_url}"
  filename   = "${path.module}/debug/${terraform.workspace}/configId.txt"
}
resource "local_file" "randomPart" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${random_id.randomPart.b64_url}"
  filename   = "${path.module}/debug/${terraform.workspace}/randomPart.txt"
}
resource "local_file" "bastionAmiId" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.aws_ami.bastionhostPackerAmi.id}"
  filename   = "${path.module}/debug/${terraform.workspace}/bastionAmiId.txt"
}
