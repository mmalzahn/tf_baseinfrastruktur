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
