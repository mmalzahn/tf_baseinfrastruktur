provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "C:/Users/matthias/.aws/credentials"
  profile                 = "tfinfrauser"
}

resource "aws_lb" "externerDemoElb" {
  name               = "externerDemoElb"
  internal           = "false"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.dmz1.id}", "${aws_subnet.dmz2.id}", "${aws_subnet.dmz3.id}"]

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
  }
}

resource "aws_lb_listener" "demoHTTPS" {
  load_balancer_arn = "${aws_lb.externerDemoElb.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.TG_Demo_HTTPS.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG_Demo_HTTPS" {
  name              = "TG-Demo-HTTPS"
  port              = "444"
  protocol          = "TCP"
  proxy_protocol_v2 = "true"
  target_type       = "instance"
  vpc_id            = "${aws_vpc.DemoVPC.id}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_demoHTTPS" {
  target_id        = "${aws_instance.nginx_DMZ.id}"
  port             = 444
  target_group_arn = "${aws_lb_target_group.TG_Demo_HTTPS.arn}"
}

resource "aws_lb" "externerDCAElb" {
  name               = "externerDCAElb"
  internal           = "false"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.dmz1.id}", "${aws_subnet.dmz2.id}", "${aws_subnet.dmz3.id}"]

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
  }
}

resource "aws_lb_listener" "dcaHTTP" {
  load_balancer_arn = "${aws_lb.externerDCAElb.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.TG_DCA_HTTP.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "dcaHTTPS" {
  load_balancer_arn = "${aws_lb.externerDCAElb.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.TG_DCA_HTTPS.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG_DCA_HTTP" {
  name              = "TG-DCA-HTTP"
  port              = "81"
  protocol          = "TCP"
  proxy_protocol_v2 = "true"
  target_type       = "instance"
  vpc_id            = "${aws_vpc.DemoVPC.id}"
}

resource "aws_lb_target_group" "TG_DCA_HTTPS" {
  name              = "TG-DCA-HTTPS"
  port              = "445"
  protocol          = "TCP"
  proxy_protocol_v2 = "true"
  target_type       = "instance"
  vpc_id            = "${aws_vpc.DemoVPC.id}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_dcaHTTPS" {
  target_id        = "${aws_instance.nginx_DMZ.id}"
  port             = 445
  target_group_arn = "${aws_lb_target_group.TG_DCA_HTTPS.arn}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_dcaHTTP" {
  target_id        = "${aws_instance.nginx_DMZ.id}"
  port             = 81
  target_group_arn = "${aws_lb_target_group.TG_DCA_HTTP.arn}"
}

resource "aws_instance" "nginx_DMZ" {
  ami           = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.dmz1.id}"

  vpc_security_group_ids = [
    "${aws_security_group.SG_HTTPS_IN_anywhere.id}",
    "${aws_security_group.SG_SSH_IN_from_Jumphost.id}",
    "${aws_security_group.SG_TCP444-445Stream_IN_anywhere.id}",
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

data "template_file" "installscript_dmz" {
  template = "${file("installdocker.tpl")}"
  vars {
      file_system_id = "${aws_efs_file_system.efs_dockerStoreDmz.id}"
      efs_directory = "/efs"
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
# 
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

resource "aws_efs_file_system" "efs_dockerStoreDmz" {
  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
    Name = "DMZ Dockerstorage"
  }
}

resource "aws_efs_mount_target" "EFS_DMZ1" {
  file_system_id  = "${aws_efs_file_system.efs_dockerStoreDmz.id}"
  subnet_id       = "${aws_subnet.dmz1.id}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}

resource "aws_efs_mount_target" "EFS_DMZ2" {
  file_system_id  = "${aws_efs_file_system.efs_dockerStoreDmz.id}"
  subnet_id       = "${aws_subnet.dmz2.id}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}

resource "aws_efs_mount_target" "EFS_DMZ3" {
  file_system_id  = "${aws_efs_file_system.efs_dockerStoreDmz.id}"
  subnet_id       = "${aws_subnet.dmz3.id}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}

resource "aws_route53_record" "dca_jumphost" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.jumphost_DMZ"]
  name            = "jumphost"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.jumphost_DMZ.public_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "dca_dmzProxy" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.nginx_DMZ"]
  name            = "dmzproxy"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.nginx_DMZ.public_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "dca_dmzProxyIntern" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.nginx_DMZ"]
  name            = "dmzproxyintern"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.nginx_DMZ.private_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "elb_demo_extern" {
  allow_overwrite = "true"
  depends_on      = ["aws_lb.externerDemoElb"]
  name            = "elbdemoextern"
  ttl             = "60"
  type            = "CNAME"
  records         = ["${aws_lb.externerDemoElb.dns_name}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

data "aws_route53_zone" "dca_poc_domain" {
  name = "dca-poc.de."
}

data "aws_route53_zone" "dca_internal_domain" {
  name         = "dca.internal."
  private_zone = "true"
}
