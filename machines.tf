resource "aws_instance" "nginx_DMZ" {
   ami = "${lookup(var.aws_amis, var.aws_region)}"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.dmz1.id}"
   vpc_security_group_ids = [
     "${aws_security_group.SG_HTTPS_IN_anywhere.id}",
     "${aws_security_group.SG_SSH_IN_from_Jumphost.id}",
     "${aws_security_group.SG_TCP444-445Stream_IN_anywhere.id}"
     ]
   associate_public_ip_address ="true"
   key_name = "CSA-DemoVPCKey1"
   user_data = "${file("./installdocker.sh")}"
   tags {
     Name = "DMZ-Proxy"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}
resource "aws_instance" "internerDockerhost" {
   ami = "${lookup(var.aws_amis, var.aws_region)}"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.Backend1.id}"
   vpc_security_group_ids = [
    "${aws_security_group.SG_HTTPS_IN_from_Revproxy.id}",
    "${aws_security_group.SG_SSH_IN_from_Jumphost.id}",
    "${aws_security_group.SG_TCP444-445Stream_IN_from_Revproxy.id}"
    ]
   associate_public_ip_address ="false"
   key_name = "CSA-DemoVPCKey1"
   user_data = "${file("./installdocker.sh")}"
   tags {
     Name = "interner Dockerhost"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}

resource "aws_instance" "jumphost_DMZ" {
   ami = "${lookup(var.aws_amis, var.aws_region)}"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.dmz1.id}"
   vpc_security_group_ids = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
   key_name = "CSA-DemoVPCKey1"
   associate_public_ip_address ="true"
   tags {
     Name = "DMZ-LinuxJumphost"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}