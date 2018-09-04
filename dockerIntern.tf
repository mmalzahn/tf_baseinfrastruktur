data "template_file" "installscript_intern" {
  template = "${file("installdocker.tpl")}"

  vars {
    file_system_id = "${data.terraform_remote_state.baseInfra.efs_filesystem_id}"
    efs_directory  = "/efs"
  }
}

resource "aws_instance" "internerDockerhost" {
  ami           = "${data.aws_ami.packerAmi.id}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${element(data.terraform_remote_state.baseInfra.subnet_ids_backend,0)}"

  vpc_security_group_ids = [
    "${lookup(data.terraform_remote_state.baseInfra.secgroups,"ssh_bastion_in")}",
    "${lookup(data.terraform_remote_state.baseInfra.secgroups,"dockersock_bastion_in")}",
  ]

  associate_public_ip_address = "false"
  key_name                    = "${var.aws_key_name}"
  user_data                   = "${data.template_file.installscript_intern.rendered}"

  lifecycle {
    ignore_changes        = ["tags.tf_created"]
    create_before_destroy = "true"
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "DockerhostIntern_${lookup(local.common_tags,"tf_project")}_${lookup(local.common_tags,"tf_responsible")}"
              )
              )}"
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
