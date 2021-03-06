resource "aws_vpc" "mainvpc" {
  cidr_block           = "${var.vpc_cdir}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${lookup(local.common_tags,"tf_project_name")}_${terraform.workspace}_VPC"
              )
              )}"
}

resource "aws_subnet" "DMZ" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(var.vpc_cdir,8 , count.index + var.subnetoffset_dmz)}"
  vpc_id                  = "${aws_vpc.mainvpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index]}"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}DMZ_${count.index}_${data.aws_availability_zones.azs.names[count.index]}_${replace(replace(cidrsubnet(var.vpc_cdir, 8, count.index + 20),".","-"),"/","_")}"
              )
              )}"
}

resource "aws_subnet" "Backend" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(var.vpc_cdir, 8, count.index + var.subnetoffset_intra)}"
  vpc_id                  = "${aws_vpc.mainvpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index]}"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}Backend_${count.index}_${data.aws_availability_zones.azs.names[count.index]}_${replace(replace(cidrsubnet(var.vpc_cdir, 8, count.index),".","-"),"/","_")}"
              )
              )}"
}
resource "aws_subnet" "ServicesBackend" {
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(var.vpc_cdir, 8, count.index + var.subnetoffset_service)}"
  vpc_id                  = "${aws_vpc.mainvpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index]}"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}ServicesBackend_${count.index}_${data.aws_availability_zones.azs.names[count.index]}_${replace(replace(cidrsubnet(var.vpc_cdir, 8, count.index + 200),".","-"),"/","_")}"
              )
              )}"
}

resource "aws_internet_gateway" "aws_IGW" {
  vpc_id = "${aws_vpc.mainvpc.id}"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}IGW_${lookup(local.common_tags,"tf_project_name")}"
              )
              )}"
}

resource "aws_eip" "nat_gw_eip" {
  count = "${var.optimal_design ? var.az_count : 1}"
  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}EIP_NAT_GW_${lookup(local.common_tags,"tf_project_name")}_${count.index}"
              )
              )}"
}

resource "aws_nat_gateway" "aws_dmz_nat_gw" {
  count = "${var.optimal_design ? var.az_count : 1}"
  allocation_id = "${element(aws_eip.nat_gw_eip.*.id,count.index)}"
  subnet_id     = "${element(aws_subnet.DMZ.*.id,count.index)}"

  lifecycle {
    ignore_changes = ["tags"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}NATGW_${lookup(local.common_tags,"tf_project_name")}_${count.index +1}"
              )
              )}"

  depends_on = ["aws_eip.nat_gw_eip"]
}

resource "aws_route_table" "RT_DMZ" {
  vpc_id = "${aws_vpc.mainvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.aws_IGW.id}"
  }

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}RT_DMZ_${lookup(local.common_tags,"tf_project_name")}"
              )
              )}"
}

resource "aws_route_table" "RT_Backend" {
  count = "${var.optimal_design ? var.az_count : 1}"
  vpc_id = "${aws_vpc.mainvpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.aws_dmz_nat_gw.*.id,count.index)}"
  }

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}RT_Backend_${lookup(local.common_tags,"tf_project_name")}"
              )
              )}"
}

resource "aws_route_table_association" "RT_add_DMZ" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.DMZ.*.id,count.index)}"
  route_table_id = "${aws_route_table.RT_DMZ.id}"
}

resource "aws_route_table_association" "RT_add_Backend" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.Backend.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.RT_Backend.*.id,count.index)}"
}
resource "aws_route_table_association" "RT_add_ServicesBackend" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.ServicesBackend.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.RT_Backend.*.id,count.index)}"
}
