provider "aws" {
   region = "eu-west-1"
   shared_credentials_file = "C:/Users/matthias/.aws/credentials"
   profile = "tfinfrauser"
}
variable "vpc_cdir" {
   default = "10.20.0.0/16"
}

variable "tag_mm_belong" {
   default = "TerraDemo"
}


resource "aws_vpc" "DemoVPC" {
   cidr_block = "${var.vpc_cdir}"
   enable_dns_hostnames = "true"
   enable_dns_support = "true"

   tags {
       Name = "DMZ1"
       responsible = "Matthias Malzahn"
       mm_belong = "${var.tag_mm_belong}"
   }
}

resource "aws_subnet" "dmz1" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 210)}"
   map_public_ip_on_launch = "true"
   availability_zone = "eu-west-1a"
   tags {
     Name = "DMZ - AZ1"
     responsible = "Matthias Malzahn"
       mm_belong = "${var.tag_mm_belong}"
   }
}
resource "aws_subnet" "dmz2" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 220)}"
   map_public_ip_on_launch = "true"
   availability_zone = "eu-west-1b"
   tags {
     Name = "DMZ - AZ2"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
   }
}
resource "aws_subnet" "dmz3" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 230)}"
   map_public_ip_on_launch = "true"
   availability_zone = "eu-west-1c"
   tags {
     Name = "DMZ - AZ3"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
   }
}
resource "aws_subnet" "Backend1" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 110)}"
   map_public_ip_on_launch = "false"
   availability_zone = "eu-west-1a"
   tags {
     Name = "Backend - AZ1"
     responsible = "Matthias Malzahn"
       mm_belong = "${var.tag_mm_belong}"
   }
}
resource "aws_subnet" "Backend2" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 120)}"
   map_public_ip_on_launch = "false"
   availability_zone = "eu-west-1b"
   tags {
     Name = "Backend - AZ2"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
   }
}
resource "aws_subnet" "Backend3" {
   vpc_id = "${aws_vpc.DemoVPC.id}"
   cidr_block = "${cidrsubnet(var.vpc_cdir, 8, 130)}"
   map_public_ip_on_launch = "false"
   availability_zone = "eu-west-1c"
   tags {
     Name = "Backend - AZ3"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
   }
}

resource "aws_internet_gateway" "aws_IGW" {
    vpc_id ="${aws_vpc.DemoVPC.id}"
    tags {
        Name = "IGW - Demo VPC"
        responsible = "Matthias Malzahn"
        mm_belong = "${var.tag_mm_belong}"
    }
}

resource "aws_eip" "nat_gw_eip" {
  tags {
    Name = "NAT GW DMZ1"
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
  }
}


resource "aws_nat_gateway" "aws_dmz1_nat_gw" {
  allocation_id = "${aws_eip.nat_gw_eip.id}"
  subnet_id     = "${aws_subnet.dmz1.id}"
  tags {
    Name = "NAT GW DMZ1"
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
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
  }
}

resource "aws_route_table" "RT_Backend" {
  vpc_id = "${aws_vpc.DemoVPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.aws_dmz1_nat_gw.id}"
  }
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    Name = "RT Backend1-3"
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

resource "aws_security_group" "SG_HTTPS_IN" {
  name        = "SG_HTTPS_IN"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 443
    to_port     = 443
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
  }
}

resource "aws_security_group_rule" "HTTP_IN" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.SG_HTTPS_IN.id}"
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
  }
}

resource "aws_efs_file_system" "efs_dockerStoreDmz" {
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
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



resource "aws_instance" "nginx_DMZ" {
   ami = "ami-e4515e0e"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.dmz1.id}"
   vpc_security_group_ids = ["${aws_security_group.SG_HTTPS_IN.id}"]
   tags {
     Name = "DMZ-Proxy"
     responsible = "Matthias Malzahn"
     mm_belong = "${var.tag_mm_belong}"
   }
}
