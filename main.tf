provider "aws" {
   region = "${var.aws_region}"
   shared_credentials_file = "C:/Users/matthias/.aws/credentials"
   profile = "tfinfrauser"
}
resource "aws_lb" "externerDemoElb" {
  name = "externerDemoElb"
  internal = "false"
  load_balancer_type = "network"
  subnets = ["${aws_subnet.dmz1.id}","${aws_subnet.dmz2.id}","${aws_subnet.dmz3.id}"]
   tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
   }
}

resource "aws_lb_listener" "demoHTTPS" {
  load_balancer_arn = "${aws_lb.externerDemoElb.arn}"
  port = "443"
  protocol = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.TG_Demo_HTTPS.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG_Demo_HTTPS" {
  name = "TG-Demo-HTTPS"
  port = "444"
  protocol = "TCP"
  proxy_protocol_v2 = "true"
  target_type = "instance"
  vpc_id = "${aws_vpc.DemoVPC.id}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_demoHTTPS" {
  target_id = "${aws_instance.nginx_DMZ.id}"
  port = 444
  target_group_arn = "${aws_lb_target_group.TG_Demo_HTTPS.arn}"
}

resource "aws_lb" "externerDCAElb" {
  name = "externerDCAElb"
  internal = "false"
  load_balancer_type = "network"
  subnets = ["${aws_subnet.dmz1.id}","${aws_subnet.dmz2.id}","${aws_subnet.dmz3.id}"]
   tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
   }
}

resource "aws_lb_listener" "dcaHTTP" {
  load_balancer_arn = "${aws_lb.externerDCAElb.arn}"
  port = "80"
  protocol = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.TG_DCA_HTTP.arn}"
    type             = "forward"
  }
}
resource "aws_lb_listener" "dcaHTTPS" {
  load_balancer_arn = "${aws_lb.externerDCAElb.arn}"
  port = "443"
  protocol = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.TG_DCA_HTTPS.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG_DCA_HTTP" {
  name = "TG-DCA-HTTP"
  port = "81"
  protocol = "TCP"
  proxy_protocol_v2 = "true"
  target_type = "instance"
  vpc_id = "${aws_vpc.DemoVPC.id}"
}


resource "aws_lb_target_group" "TG_DCA_HTTPS" {
  name = "TG-DCA-HTTPS"
  port = "445"
  protocol = "TCP"
  proxy_protocol_v2 = "true"
  target_type = "instance"
  vpc_id = "${aws_vpc.DemoVPC.id}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_dcaHTTPS" {
  target_id = "${aws_instance.nginx_DMZ.id}"
  port = 445
  target_group_arn = "${aws_lb_target_group.TG_DCA_HTTPS.arn}"
}
resource "aws_lb_target_group_attachment" "addDmzDocker2TG_dcaHTTP" {
  target_id = "${aws_instance.nginx_DMZ.id}"
  port = 81
  target_group_arn = "${aws_lb_target_group.TG_DCA_HTTP.arn}"
}
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

resource "aws_efs_file_system" "efs_dockerStoreDmz" {
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
  }
}

resource "aws_efs_mount_target" "EFS_DMZ1" {
  file_system_id = "${aws_efs_file_system.efs_dockerStoreDmz.id}"
  subnet_id = "${aws_subnet.dmz1.id}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}
resource "aws_efs_mount_target" "EFS_DMZ2" {
  file_system_id = "${aws_efs_file_system.efs_dockerStoreDmz.id}"
  subnet_id = "${aws_subnet.dmz2.id}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}
resource "aws_efs_mount_target" "EFS_DMZ3" {
  file_system_id = "${aws_efs_file_system.efs_dockerStoreDmz.id}"
  subnet_id = "${aws_subnet.dmz3.id}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}

resource "aws_efs_file_system" "efs_dockerStoreBackend" {
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
  }
}

resource "aws_efs_mount_target" "EFS_Backend1" {
  file_system_id = "${aws_efs_file_system.efs_dockerStoreBackend.id}"
  subnet_id = "${aws_subnet.Backend1.id}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}
resource "aws_efs_mount_target" "EFS_Backend2" {
  file_system_id = "${aws_efs_file_system.efs_dockerStoreBackend.id}"
  subnet_id = "${aws_subnet.Backend2.id}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}
resource "aws_efs_mount_target" "EFS_Backend3" {
  file_system_id = "${aws_efs_file_system.efs_dockerStoreBackend.id}"
  subnet_id = "${aws_subnet.Backend3.id}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}

resource "aws_route53_record" "dca_jumphost" {
  allow_overwrite = "true"
  depends_on = ["aws_instance.jumphost_DMZ"]
  name = "jumphost"
  ttl = "60"
  type = "A"
  records =["${aws_instance.jumphost_DMZ.public_ip}"]
  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
resource "aws_route53_record" "dca_dmzProxy" {
  allow_overwrite = "true"
  depends_on = ["aws_instance.nginx_DMZ"]
  name = "dmzproxy"
  ttl = "60"
  type = "A"
  records =["${aws_instance.nginx_DMZ.public_ip}"]
  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
resource "aws_route53_record" "dca_dockerhost_intern" {
  allow_overwrite = "true"
  depends_on = ["aws_instance.internerDockerhost"]
  name = "internerDockerhost"
  ttl = "60"
  type = "A"
  records =["${aws_instance.internerDockerhost.private_ip}"]
  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
resource "aws_route53_record" "internal_internerDockerhost" {
  allow_overwrite = "true"
  depends_on = ["aws_instance.internerDockerhost"]
  name = "internerDockerhost"
  ttl = "60"
  type = "A"
  records =["${aws_instance.internerDockerhost.private_ip}"]
  zone_id = "${data.aws_route53_zone.dca_internal_domain.zone_id}"
}

resource "aws_route53_record" "elb_demo_extern" {
  allow_overwrite = "true"
  depends_on = ["aws_lb.externerDemoElb"]
  name = "elbdemoextern"
  ttl = "60"
  type = "CNAME"
  records =["${aws_lb.externerDemoElb.dns_name}"]
  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_security_group" "SG_HTTPS_IN_anywhere" {
  name        = "SG_HTTPS_IN"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
    Name = "SG_HTTPS_IN_anywhere"
  }
}

resource "aws_security_group" "SG_TCP444-445Stream_IN_anywhere" {
  name        = "SG_TCP444-445Stream_IN_anywhere"
  description = "Allow Port444-445 TCP Stream inbound traffic"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 444
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
    Name = "SG_TCP444-445Stream_IN_anywhere"
  }
}
resource "aws_security_group" "SG_TCP444-445Stream_IN_from_Revproxy" {
  name        = "SG_TCP444-445Stream_IN_from_Revproxy"
  description = "Allow Port 444-445 TCP Stream inbound traffic from Revproxy"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 444
    to_port     = 445
    protocol    = "tcp"
    security_groups = ["${aws_security_group.SG_TCP444-445Stream_IN_anywhere.id}"]
  }
  ingress {
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    security_groups = ["${aws_security_group.SG_TCP444-445Stream_IN_anywhere.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
    Name = "SG_TCP444-445Stream_IN_from_Revproxy"
  }
}
resource "aws_security_group" "SG_EFS_IN_FROM_VPC" {
  name        = "SG_EFS_IN_VPC"
  description = "Allow EFS traffic from VPC"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
    Name = "SG_EFS_IN_VPC"
  }
}
resource "aws_security_group" "SG_HTTPS_IN_from_Revproxy" {
  name        = "SG_HTTPS_IN_from_Revproxy"
  description = "Allow HTTPS inbound traffic from Revproxy"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = ["${aws_security_group.SG_HTTPS_IN_anywhere.id}"]
  }
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.SG_HTTPS_IN_anywhere.id}"]
  }
  egress {
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
    Name = "SG_HTTPS_IN_from_Revproxy"
  }
}
resource "aws_security_group" "SG_SSH_IN_from_anywhere" {
  name        = "SG_SSH_IN_from_anywhere"
  description = "Allow SSH inbound traffic from anywhere"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
    Name = "SG_SSH_IN_from_anywhere"
  }
}
resource "aws_security_group" "SG_SSH_IN_from_Jumphost" {
  name        = "SG_SSH_IN_from_Jumphost"
  description = "Allow SSH inbound traffic from Jumphost"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
  }
  egress {
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
    Name = "SG_SSH_IN_from_Jumphost"
  }
}

data "aws_route53_zone" "dca_poc_domain" {
  name = "dca-poc.de."
}

data "aws_route53_zone" "dca_internal_domain" {
  name = "dca.internal."
  private_zone = "true"
}

data "aws_availability_zones" "azs" {
  
}
resource "aws_vpc" "DemoVPC" {
   cidr_block = "${var.vpc_cdir}"
   enable_dns_hostnames = "true"
   enable_dns_support = "true"

   tags {
       Name = "DEMO VPC"
       terraform = "true"
       responsible = "Matthias Malzahn"
       mm_belong = "${var.tag_mm_belong}"
   }
}
resource "aws_subnet" "dmz1" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 210)}"
   map_public_ip_on_launch = "true"
   availability_zone = "${data.aws_availability_zones.azs.names[0]}"
   tags {
     Name = "DMZ - AZ1"
     responsible = "Matthias Malzahn"
       mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}
resource "aws_subnet" "dmz2" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 220)}"
   map_public_ip_on_launch = "true"
   availability_zone = "${data.aws_availability_zones.azs.names[1]}"
   tags {
     Name = "DMZ - AZ2"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}
resource "aws_subnet" "dmz3" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 230)}"
   map_public_ip_on_launch = "true"
   availability_zone = "${data.aws_availability_zones.azs.names[2]}"
   tags {
     Name = "DMZ - AZ3"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}
resource "aws_subnet" "Backend1" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 110)}"
   map_public_ip_on_launch = "false"
   availability_zone = "${data.aws_availability_zones.azs.names[0]}"
   tags {
     Name = "Backend - AZ1"
     responsible = "Matthias Malzahn"
       mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}
resource "aws_subnet" "Backend2" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 120)}"
   map_public_ip_on_launch = "false"
   availability_zone = "${data.aws_availability_zones.azs.names[1]}"
   tags {
     Name = "Backend - AZ2"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}
resource "aws_subnet" "Backend3" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 130)}"
   map_public_ip_on_launch = "false"
   availability_zone = "${data.aws_availability_zones.azs.names[2]}"
   tags {
     Name = "Backend - AZ3"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}

resource "aws_internet_gateway" "aws_IGW" {
    vpc_id ="${aws_vpc.DemoVPC.id}"
    tags {
        Name = "IGW - Demo VPC"
        responsible = "Matthias Malzahn"
        mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
    }
}

resource "aws_eip" "nat_gw_eip" {
  tags {
    Name = "NAT GW DMZ1"
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
  }
}


resource "aws_nat_gateway" "aws_dmz1_nat_gw" {
  allocation_id = "${aws_eip.nat_gw_eip.id}"
  subnet_id     = "${aws_subnet.dmz1.id}"
  tags {
    Name = "NAT GW DMZ1"
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
  }
  depends_on =["aws_eip.nat_gw_eip"]
}

resource "aws_route_table" "RT_DMZ" {
  vpc_id = "${aws_vpc.DemoVPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.aws_IGW.id}"
  }
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    Name = "RT DMZ1-3"
       terraform = "true"
  }
}

resource "aws_route_table" "RT_Backend" {
  vpc_id = "${aws_vpc.DemoVPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.aws_dmz1_nat_gw.id}"
  }
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    Name = "RT Backend1-3"
       terraform = "true"
  }
}

resource "aws_route_table_association" "RT_add_DMZ1" {
  subnet_id = "${aws_subnet.dmz1.id}"
  route_table_id = "${aws_route_table.RT_DMZ.id}"
}
resource "aws_route_table_association" "RT_add_DMZ2" {
  subnet_id = "${aws_subnet.dmz2.id}"
  route_table_id = "${aws_route_table.RT_DMZ.id}"
}
resource "aws_route_table_association" "RT_add_DMZ3" {
  subnet_id = "${aws_subnet.dmz3.id}"
  route_table_id = "${aws_route_table.RT_DMZ.id}"
}

resource "aws_route_table_association" "RT_add_Backend1" {
  subnet_id = "${aws_subnet.Backend1.id}"
  route_table_id = "${aws_route_table.RT_Backend.id}"
}
resource "aws_route_table_association" "RT_add_Backend2" {
  subnet_id = "${aws_subnet.Backend2.id}"
  route_table_id = "${aws_route_table.RT_Backend.id}"
}
resource "aws_route_table_association" "RT_add_Backend3" {
  subnet_id = "${aws_subnet.Backend3.id}"
  route_table_id = "${aws_route_table.RT_Backend.id}"
}
# variable "public_key_path" {
#   description = <<DESCRIPTION
# Path to the SSH public key to be used for authentication.
# Ensure this keypair is added to your local SSH agent so provisioners can
# connect.
# 
# Example: ~/.ssh/terraform.pub
# DESCRIPTION
# }
# 
# 
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}


variable "aws_amis" {
  default = {
    eu-west-1 = "ami-e4515e0e"
    eu-west-2 = "ami-b2b55cd5"
    us-east-2 = "ami-40142d25"
  }
}

variable "vpc_cdir" {
   default = "10.20.0.0/16"
}

variable "tag_mm_belong" {
   default = "TerraDemo"
}
