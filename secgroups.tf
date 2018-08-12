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
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
       terraform = "true"
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
       terraform = "true"
  }
}

resource "aws_security_group" "SG_HTTPS_IN_from_Revproxy" {
  name        = "SG_HTTPS_IN_from_Revproxy"
  description = "Allow HTTPS inbound traffic from Revproxy"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = ["${aws_security_group.SG_HTTPS_IN_anywhere.id}"]
  }
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.SG_HTTPS_IN_anywhere.id}"]
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
       terraform = "true"
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
    from_port       = 0
    to_port         = 65534
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
  }
}
resource "aws_security_group" "SG_SSH_IN_from_Jumphost" {
  name        = "SG_SSH_IN_from_Jumphost"
  description = "Allow SSH inbound traffic from Jumphost"
  vpc_id      = "${aws_vpc.DemoVPC.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
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
    terraform = "true"
  }
}
