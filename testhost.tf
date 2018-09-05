resource "aws_instance" "internerTesthost" {
  count                       = "${var.testhost_deploy ? 1 :0}"
  ami                         = "${data.aws_ami.bastionhostPackerAmi.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(aws_subnet.Backend.*.id,count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.SG_SSH_IN_from_Bastionhost.id}"]
  key_name                    = "${var.aws_key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastionIamProf.name}"
  user_data                   = "${data.template_file.bastionhostUserdata.rendered}"
  associate_public_ip_address = "false"
  volume_tags                 = "${local.common_tags}"

  depends_on = [
    "aws_iam_role.bastionS3pubkeyBucket",
    "aws_subnet.Backend",
  ]

  lifecycle {
    ignore_changes = [
      "tags.tf_created",
      "volume_tags.tf_created",
    ]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}intern_LinuxTesthost_${count.index + 1}_${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_route53_record" "internerTesthost" {
  count           = "${var.testhost_deploy ? 1 :0}"
  allow_overwrite = "true"
  depends_on      = ["aws_instance.internerTesthost"]
  name            = "internertesthost.${terraform.workspace}"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.internerTesthost.private_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
