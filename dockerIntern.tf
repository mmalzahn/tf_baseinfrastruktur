data "template_file" "installscript_intern" {
  template = "${file("installdocker.tpl")}"

  vars {
    file_system_id = "${aws_efs_file_system.efs_dockerStoreBackend.id}"
    efs_directory  = "/efs"
  }
}

resource "aws_instance" "internerDockerhost" {
  ami           = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.Backend.0.id}"

  vpc_security_group_ids = [
    "${aws_security_group.SG_HTTPS_IN_from_Revproxy.id}",
    "${aws_security_group.SG_SSH_IN_from_Jumphost.id}",
    "${aws_security_group.SG_TCP444-445Stream_IN_from_Revproxy.id}",
    "${aws_security_group.SG_HTTPS_IN_from_VPC.id}",
    "${aws_security_group.SG_DockerSocket_IN_from_Jumphost.id}",
  ]

  depends_on = [
    "aws_efs_mount_target.EFS_Backend",
    "aws_nat_gateway.aws_dmz1_nat_gw",
  ]

  associate_public_ip_address = "false"
  key_name                    = "CSA-DemoVPCKey1"
  user_data                   = "${data.template_file.installscript_intern.rendered}"
  tags = "${merge(local.common_tags,map("Name", "interner Dockerhost"))}"
}

resource "aws_route53_record" "dca_dockerhost_intern" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.internerDockerhost"]
  name            = "internerDockerhost"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.internerDockerhost.private_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "internal_internerDockerhost" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.internerDockerhost"]
  name            = "internerDockerhost"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.internerDockerhost.private_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_internal_domain.zone_id}"
}
