resource "local_file" "bastionInstallFile" {
  count      = "${var.mm_debug}"
  content    = "${data.template_file.bastionhostUserdata.rendered}"
  filename   = "${path.module}/debug/bastion_userdata.txt"
  depends_on = ["aws_instance.bastionhost"]
}
resource "local_file" "iamPolicy" {
  count      = "${var.mm_debug}"
  content    = "${data.template_file.iampolicy.rendered}"
  filename   = "${path.module}/debug/iampolicy.txt"
  depends_on = ["aws_instance.bastionhost"]
}
resource "local_file" "randomConfigId" {
  count      = "${var.mm_debug}"
  content    = "${random_id.configId.b64_url}"
  filename   = "${path.module}/debug/configId.txt"
}
resource "local_file" "randomPart" {
  count      = "${var.mm_debug}"
  content    = "${random_id.randomPart.b64_url}"
  filename   = "${path.module}/debug/randomPart.txt"
}
resource "local_file" "bastionAmiId" {
  count      = "${var.mm_debug}"
  content    = "${data.aws_ami.bastionhostPackerAmi.id}"
  filename   = "${path.module}/debug/bastionAmiId.txt"
}
