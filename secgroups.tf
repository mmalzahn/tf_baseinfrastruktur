resource "aws_security_group" "SG_SSH_IN_from_Bastionhost" {
  name        = "SG_SSH_IN_from_Bastionhost_${lookup(local.common_tags,"tf_project_name")}"
  description = "Allow SSH inbound traffic from Bastionhost for Project ${lookup(local.common_tags,"tf_project_name")}"
  vpc_id      = "${aws_vpc.mainvpc.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
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
              "Name", "SG_SSH_IN_from_Bastionhost_${lookup(local.common_tags,"tf_project_name")}"
              )
              )}"
}

resource "aws_security_group" "SG_RDP_IN_from_Bastionhost" {
  name        = "SG_RDP_IN_from_Bastionhost_${lookup(local.common_tags,"tf_project_name")}"
  description = "Allow RDP inbound traffic from Bastionhost for Project ${lookup(local.common_tags,"tf_project_name")}"
  vpc_id      = "${aws_vpc.mainvpc.id}"

  ingress {
    from_port       = 3389
    to_port         = 3389
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
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
              "Name", "SG_RDP_IN_from_Bastionhost_${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}
