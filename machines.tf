data "template_file" "installscript_dmz" {
  template = "${file("installdocker.tpl")}"

  vars {
    file_system_id = "${aws_efs_file_system.efs_dockerStoreDmz.id}"
    efs_directory  = "/efs"
  }
}

# resource "aws_instance" "internerDockerhost2" {
#    ami = "${lookup(var.aws_amis, var.aws_region)}"
#    instance_type = "t2.micro"
#    subnet_id = "${aws_subnet.Backend2.id}"
#    vpc_security_group_ids = [
#     "${aws_security_group.SG_HTTPS_IN_from_Revproxy.id}",
#     "${aws_security_group.SG_SSH_IN_from_Jumphost.id}",
#     "${aws_security_group.SG_TCP444-445Stream_IN_from_Revproxy.id}",
#     "${aws_security_group.SG_HTTPS_IN_from_VPC.id}"
#     ]
#    associate_public_ip_address ="false"
#    key_name = "CSA-DemoVPCKey1"
#    user_data = "${file("./installdocker.sh")}"
#    tags {
#      Name = "interner Dockerhost"
#      responsible = "${var.tag_responsibel}"
#      mm_belong = "${var.tag_mm_belong}"
#        terraform = "true"
#    }
# }

resource "aws_instance" "nginx_DMZ" {
  ami           = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.dmz1.id}"

  vpc_security_group_ids = [
    "${aws_security_group.SG_HTTPS_IN_anywhere.id}",
    "${aws_security_group.SG_SSH_IN_from_Jumphost.id}",
    "${aws_security_group.SG_TCP444-445Stream_IN_anywhere.id}",
    "${aws_security_group.SG_DockerSocket_IN_from_Jumphost.id}",
  ]

  depends_on                  = ["aws_efs_mount_target.EFS_DMZ1", "aws_internet_gateway.aws_IGW"]
  associate_public_ip_address = "true"
  key_name                    = "CSA-DemoVPCKey1"
  user_data                   = "${data.template_file.installscript_dmz.rendered}"

  tags {
    Name        = "DMZ-Proxy"
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
  }
}

resource "aws_instance" "jumphost_DMZ" {
  ami                         = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.dmz1.id}"
  vpc_security_group_ids      = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
  key_name                    = "CSA-DemoVPCKey1"
  associate_public_ip_address = "true"

  tags {
    Name        = "DMZ-LinuxJumphost"
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
  }
}
