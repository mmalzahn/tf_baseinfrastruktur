resource "aws_security_group" "SG_HTTPS_IN_anywhere" {
  name        = "SG_HTTPS_IN"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = "${aws_vpc.mainvpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
              "Name", "SG_HTTPS_IN - ${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_security_group" "SG_HTTPS_IN_from_VPC" {
  name        = "SG_HTTPS_IN_from_VPC"
  description = "Allow HTTPS inbound traffic from VPC"
  vpc_id      = "${aws_vpc.mainvpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.mainvpc.cidr_block}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
              "Name", "SG_HTTPS_IN_from_VPC - ${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_security_group" "SG_SSH_IN_from_Jumphost" {
  name        = "SG_SSH_IN_from_Jumphost"
  description = "Allow SSH inbound traffic from Jumphost"
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
              "Name", "SG_SSH_IN_from_Jumphost - ${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_security_group" "SG_DockerSocket_IN_from_Bastionhost" {
  name        = "SG_DockerSocket_IN_from_Bastionhost"
  description = "Allow SSH inbound traffic from Bastionhost"
  vpc_id      = "${aws_vpc.mainvpc.id}"

  ingress {
    from_port       = 2375
    to_port         = 2376
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
              "Name", "SG_DockerSocket_IN_from_Bastionhost - ${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_security_group" "SG_RDP_IN_from_Bastionhost" {
  name        = "SG_RDP_IN_from_Bastionhost"
  description = "Allow RDP inbound traffic from Bastionhost"
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
              "Name", "SG_RDP_IN_from_Bastionhost - ${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}
