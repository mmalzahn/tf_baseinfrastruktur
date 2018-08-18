data "aws_availability_zones" "azs" {
  
}
resource "aws_vpc" "DemoVPC" {
   cidr_block = "${var.vpc_cdir}"
   enable_dns_hostnames = "true"
   enable_dns_support = "true"
   tags {
       Name = "DEMO VPC - ${var.tag_mm_belong}"
       terraform = "true"
       responsible = "${var.tag_responsibel}"
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
     responsible = "${var.tag_responsibel}"
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
     responsible = "${var.tag_responsibel}"
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
     responsible = "${var.tag_responsibel}"
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
    responsible = "${var.tag_responsibel}"
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
    responsible = "${var.tag_responsibel}"
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
     responsible = "${var.tag_responsibel}"
     mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
   }
}

resource "aws_internet_gateway" "aws_IGW" {
    vpc_id ="${aws_vpc.DemoVPC.id}"
    tags {
        Name = "IGW - Demo VPC"
        responsible = "${var.tag_responsibel}"
        mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
    }
}

resource "aws_eip" "nat_gw_eip" {
  tags {
    Name = "NAT GW DMZ1"
    responsible = "${var.tag_responsibel}"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
  }
}


resource "aws_nat_gateway" "aws_dmz1_nat_gw" {
  allocation_id = "${aws_eip.nat_gw_eip.id}"
  subnet_id     = "${aws_subnet.dmz1.id}"
  tags {
    Name = "NAT GW DMZ1"
    responsible = "${var.tag_responsibel}"
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
    responsible = "${var.tag_responsibel}"
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
    responsible = "${var.tag_responsibel}"
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
