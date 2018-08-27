resource "aws_vpc" "mainvpc" {
  cidr_block           = "${var.vpc_cdir}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  lifecycle {
    ignore_changes = ["tags.tf_created", "tf_needuntil"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "VPC - ${var.tag_mm_belong}"
              )
              )}"
}

resource "aws_subnet" "DMZ" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(var.vpc_cdir, 8, count.index + 20)}"
  vpc_id                  = "${aws_vpc.mainvpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index]}"

  lifecycle {
    ignore_changes = ["tags.tf_created", "tf_needuntil"]
  }

  tags = "${local.common_tags}"
}

resource "aws_subnet" "Backend" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(var.vpc_cdir, 8, count.index)}"
  vpc_id                  = "${aws_vpc.mainvpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index]}"

  lifecycle {
    ignore_changes = ["tags.tf_created", "tf_needuntil"]
  }

  tags = "${local.common_tags}"
}

# 
# resource "aws_internet_gateway" "aws_IGW" {
#   vpc_id = "${aws_vpc.mainvpc.id}"
#   lifecycle {
#     ignore_changes = ["local.common_tags.tf_created"]
#     }
#   tags   = "${local.common_tags}"
# }
# 
# resource "aws_eip" "nat_gw_eip" {
#   lifecycle {
#     ignore_changes = ["local.common_tags.tf_created"]
#     }
#   tags = "${local.common_tags}"
# }
# 
# resource "aws_nat_gateway" "aws_dmz1_nat_gw" {
#   allocation_id = "${aws_eip.nat_gw_eip.id}"
#   subnet_id     = "${aws_subnet.DMZ.0.id}"
#   tags          = "${merge(local.common_tags,map("Name", "NAT GW DMZ1"))}"
#   depends_on    = ["aws_eip.nat_gw_eip"]
# }
# 
# resource "aws_route_table" "RT_DMZ" {
#   vpc_id = "${aws_vpc.mainvpc.id}"
# 
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = "${aws_internet_gateway.aws_IGW.id}"
#   }
# 
#   tags = "${merge(local.common_tags,map("Name", "RT DMZ1-3"))}"
# }
# 
# resource "aws_route_table" "RT_Backend" {
#   vpc_id = "${aws_vpc.mainvpc.id}"
# 
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = "${aws_nat_gateway.aws_dmz1_nat_gw.id}"
#   }
# 
#   tags = "${merge(local.common_tags,map("Name", "RT Backend1-3"))}"
# }
# 
# resource "aws_route_table_association" "RT_add_DMZ" {
#   count          = "${var.az_count}"
#   subnet_id      = "${element(aws_subnet.DMZ.*.id,count.index)}"
#   route_table_id = "${aws_route_table.RT_DMZ.id}"
# }
# 
# resource "aws_route_table_association" "RT_add_Backend" {
#   subnet_id      = "${element(aws_subnet.Backend.*.id,count.index)}"
#   route_table_id = "${aws_route_table.RT_Backend.id}"
# }
# 

