resource "aws_efs_file_system" "efs_dockerStoreBackend" {
  tags = "${merge(local.common_tags,map("Name", "Backend Dockerstorage"))}"
}

resource "aws_efs_mount_target" "EFS_Backend" {
  count           = "${var.az_count}"
  file_system_id  = "${aws_efs_file_system.efs_dockerStoreBackend.id}"
  subnet_id       = "${element(aws_subnet.Backend.*.id,count.index)}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}

resource "aws_efs_file_system" "efs_dockerStoreDmz" {
  tags = "${merge(local.common_tags,map("Name", "DMZ Dockerstorage"))}"
}

resource "aws_efs_mount_target" "EFS_DMZ" {
  count           = "${var.az_count}"
  file_system_id  = "${aws_efs_file_system.efs_dockerStoreDmz.id}"
  subnet_id       = "${element(aws_subnet.DMZ.*.id,count.index)}"
  security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
}
