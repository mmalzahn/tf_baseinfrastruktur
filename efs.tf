resource "aws_efs_file_system" "efs_StorageBackend" {
  count = "${var.efs_storage ? 1 : 0}"
  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}EFS_Storagebackend-${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_efs_mount_target" "EFS_Backend" {
  count           = "${var.efs_storage ? var.az_count : 0}"
  file_system_id  = "${aws_efs_file_system.efs_StorageBackend.id}"
  subnet_id       = "${element(aws_subnet.ServicesBackend.*.id,count.index)}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}

resource "aws_security_group" "SG_EFS_IN_FROM_VPC" {
  count = "${var.efs_storage ? 1 : 0}"
  name        = "SG_EFS_IN_VPC"
  description = "Allow EFS traffic from VPC"
  vpc_id      = "${aws_vpc.mainvpc.id}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.mainvpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}SG_EFS_IN_VPC-${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}
