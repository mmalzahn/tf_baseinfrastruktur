resource "aws_instance" "bastionhost" {
  count                       = 1
  ami                         = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.DMZ.0.id}"
  vpc_security_group_ids      = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
  key_name                    = "${var.aws_key_name}"
  user_data                   = "${data.template_file.bastionhostUserdata.rendered}"
  associate_public_ip_address = "true"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "DMZ_Linuxbastionhost_${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

data "template_file" "bastionhostUserdata" {
  template = "${file("tpl/bastioninstall.tpl")}"

  vars {
    region                = "${var.aws_region}"
    bucket                = "${var.ssh_pubkey_bucket}"
    aws_access_key_id     = "${aws_iam_access_key.bastionIamUser.id}"
    aws_secret_access_key = "${aws_iam_access_key.bastionIamUser.secret}"
    prefix                = "${var.ssh_pubkey_prefix}"
  }
}

resource "aws_security_group" "SG_SSH_IN_from_anywhere" {
  name        = "SG_SSH_IN_from_anywhere_${lookup(local.common_tags,"tf_project_name")}"
  description = "Allow SSH inbound traffic from anywhere for Project ${lookup(local.common_tags,"tf_project_name")}"
  vpc_id      = "${aws_vpc.mainvpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "SG_SSH_IN_from_anywhere__${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_route53_record" "bastionhost" {
  count           = 1
  allow_overwrite = "true"
  depends_on      = ["aws_instance.bastionhost"]
  name            = "bastionhost"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.bastionhost.public_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_iam_user" "bastionIamUser" {
  name = "tf-bastion-${replace(var.project_name," ","_")}__${terraform.workspace}"
  path = "/tf/"
}

resource "aws_iam_access_key" "bastionIamUser" {
  user = "${aws_iam_user.bastionIamUser.name}"
}

data "template_file" "iampolicy" {
  template = "${file("tpl/iampol.tpl")}"

  vars {
    bucket = "${var.ssh_pubkey_bucket}"
  }
}

resource "aws_iam_user_policy" "bastionIamUserPolicy" {
  policy = "${data.template_file.iampolicy.rendered}"
  name   = "bastionIamUserPolicy"
  user   = "${aws_iam_user.bastionIamUser.name}"
}

data "template_file" "accesscfg" {
  template = <<EOF
ak = ${aws_iam_access_key.bastionIamUser.id}
sk = ${aws_iam_access_key.bastionIamUser.secret}
EOF
}

resource "local_file" "iamaccesscfg" {
  count      = "${var.mm_debug}"
  content    = "${data.template_file.accesscfg.rendered}"
  filename   = "${path.module}/debug/iamcreds"
  depends_on = ["aws_iam_access_key.bastionIamUser"]
}

resource "local_file" "bastionInstallFile" {
  count      = "${var.mm_debug}"
  content    = "${data.template_file.bastionhostUserdata.rendered}"
  filename   = "${path.module}/debug/bastion_userdata.txt"
  depends_on = ["aws_instance.bastionhost"]
}
resource "local_file" "bastionIamUserPolicy" {
  count      = "${var.mm_debug}"
  content    = "${data.template_file.iampolicy.rendered}"
  filename   = "${path.module}/debug/iampolicy.txt"
  depends_on = ["aws_iam_user_policy.bastionIamUserPolicy"]
}
