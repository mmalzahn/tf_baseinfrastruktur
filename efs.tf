# resource "aws_efs_file_system" "efs_StorageBackend" {
#   tags = "${merge(local.common_tags,map("Name", "EFS Backend Storage"))}"
# }

# resource "aws_efs_mount_target" "EFS_Backend" {
#   count           = "${var.az_count}"
#   file_system_id  = "${aws_efs_file_system.efs_StorageBackend.id}"
#   subnet_id       = "${element(aws_subnet.Backend.*.id,count.index)}"
#   security_groups = ["${aws_security_group.SG_EFS_IN_FROM_VPC.id}"]
# }

# resource "aws_security_group" "SG_EFS_IN_FROM_VPC" {
#   name        = "SG_EFS_IN_VPC"
#   description = "Allow EFS traffic from VPC"
#   vpc_id      = "${aws_vpc.mainvpc.id}"

#   ingress {
#     from_port   = 2049
#     to_port     = 2049
#     protocol    = "tcp"
#     cidr_blocks = ["${aws_vpc.mainvpc.cidr_block}"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 65534
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = "${merge(local.common_tags,map("Name", "SG_EFS_IN_VPC"))}"
# }
