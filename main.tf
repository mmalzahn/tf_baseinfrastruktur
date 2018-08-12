provider "aws" {
   region = "${var.aws_region}"
   shared_credentials_file = "C:/Users/matthias/.aws/credentials"
   profile = "tfinfrauser"
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
    gateway_id = "${aws_nat_gateway.aws_dmz1_nat_gw.id}"
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
