resource "aws_security_group" "SG_HTTPS_IN" {
  name        = "SG_HTTPS_IN"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
  }
}

resource "aws_security_group_rule" "HTTP_IN" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.SG_HTTPS_IN.id}"
}

resource "aws_security_group" "SG_EFS_IN_FROM_VPC" {
  name        = "SG_EFS_IN_VPC"
  description = "Allow EFS traffic from VPC"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
  }
}
