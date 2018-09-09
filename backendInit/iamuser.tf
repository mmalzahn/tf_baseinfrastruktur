resource "aws_iam_user" "terrauser" {
  count = "${var.newIamUser ? 1 : 0}"
  name = "tf-${random_string.userstring.result}"
  path = "/tf/"
}

resource "aws_iam_access_key" "terrauser" {
  count = "${var.newIamUser ? 1 : 0}"
  user = "${aws_iam_user.terrauser.name}"
}

resource "aws_iam_group_membership" "dcaterragroup" {
  count = "${var.newIamUser ? 1 : 0}"
  name  = "DcaBaseAutoGroup"
  group = "dca_terraTemplate"
  users = ["${aws_iam_user.terrauser.name}"]
}

data "template_file" "accesscfg" {
  count = "${var.newIamUser ? 1 : 0}"
  template = "${file("iamprofile.tpl")}"

  vars {
    profile_name = "autoIamUser"
    access_key   = "${aws_iam_access_key.terrauser.id}"
    secret_key   = "${aws_iam_access_key.terrauser.secret}"
    region       = "${var.aws_region}"
  }
}

resource "local_file" "iamaccesscfg" {
  count = "${var.newIamUser ? 1 : 0}"
  content    = "${data.template_file.accesscfg.rendered}"
  filename   = "${path.module}/cfg/iamcreds"
  depends_on = ["aws_iam_access_key.terrauser"]
}
