
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

