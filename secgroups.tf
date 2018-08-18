
resource "aws_security_group" "SG_HTTPS_IN_anywhere" {
  name        = "SG_HTTPS_IN"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

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

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
    Name        = "SG_HTTPS_IN_anywhere"
  }
}

resource "aws_security_group" "SG_TCP444-445Stream_IN_anywhere" {
  name        = "SG_TCP444-445Stream_IN_anywhere"
  description = "Allow Port444-445 TCP Stream inbound traffic"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 444
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
    Name        = "SG_TCP444-445Stream_IN_anywhere"
  }
}

resource "aws_security_group" "SG_TCP444-445Stream_IN_from_Revproxy" {
  name        = "SG_TCP444-445Stream_IN_from_Revproxy"
  description = "Allow Port 444-445 TCP Stream inbound traffic from Revproxy"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port       = 444
    to_port         = 445
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SG_TCP444-445Stream_IN_anywhere.id}"]
  }

  ingress {
    from_port       = 81
    to_port         = 81
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SG_TCP444-445Stream_IN_anywhere.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
    Name        = "SG_TCP444-445Stream_IN_from_Revproxy"
  }
}

resource "aws_security_group" "SG_EFS_IN_FROM_VPC" {
  name        = "SG_EFS_IN_VPC"
  description = "Allow EFS traffic from VPC"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.DemoVPC.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
    Name        = "SG_EFS_IN_VPC"
  }
}

resource "aws_security_group" "SG_HTTPS_IN_from_Revproxy" {
  name        = "SG_HTTPS_IN_from_Revproxy"
  description = "Allow HTTPS inbound traffic from Revproxy"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SG_HTTPS_IN_anywhere.id}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SG_HTTPS_IN_anywhere.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
    Name        = "SG_HTTPS_IN_from_Revproxy"
  }
}

resource "aws_security_group" "SG_HTTPS_IN_from_VPC" {
  name        = "SG_HTTPS_IN_from_VPC"
  description = "Allow HTTPS inbound traffic from VPC"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.DemoVPC.cidr_block}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.DemoVPC.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
    Name        = "SG_HTTPS_IN_from_VPC"
  }
}

resource "aws_security_group" "SG_SSH_IN_from_anywhere" {
  name        = "SG_SSH_IN_from_anywhere"
  description = "Allow SSH inbound traffic from anywhere"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
    Name        = "SG_SSH_IN_from_anywhere"
  }
}

resource "aws_security_group" "SG_SSH_IN_from_Jumphost" {
  name        = "SG_SSH_IN_from_Jumphost"
  description = "Allow SSH inbound traffic from Jumphost"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

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

  tags {
    responsible = "${var.tag_responsibel}"
    mm_belong   = "${var.tag_mm_belong}"
    terraform   = "true"
    Name        = "SG_SSH_IN_from_Jumphost"
  }
}
