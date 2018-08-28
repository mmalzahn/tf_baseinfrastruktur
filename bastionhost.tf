 resource "aws_instance" "bastionhost" {
   count = 1
   ami                         = "${lookup(var.aws_amis, var.aws_region)}"
   instance_type               = "t2.micro"
   subnet_id                   = "${aws_subnet.DMZ.0.id}"
   vpc_security_group_ids      = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
   key_name                    = "${var.aws_key_name}"
   user_data="${file("updateuserdata.tpl")}"
   associate_public_ip_address = "true"
  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "DMZ_Linuxbastionhost_${lookup(local.common_tags,"tf_project")}"
              )
              )}"
 }

resource "aws_security_group" "SG_SSH_IN_from_anywhere" {
  name        = "SG_SSH_IN_from_anywhere_${lookup(local.common_tags,"tf_project_name")}"
  description = "Allow SSH inbound traffic from anywhere for Project ${lookup(local.common_tags,"tf_project_name")}"
  vpc_id      = "${aws_vpc.mainvpc.id}"

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

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "SG_SSH_IN_from_anywhere__${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

 resource "aws_route53_record" "bastionhost" {
   count = 1
   allow_overwrite = "true"
   depends_on      = ["aws_instance.bastionhost"]
   name            = "bastionhost"
   ttl             = "60"
   type            = "A"
   records         = ["${aws_instance.bastionhost.public_ip}"]
   zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
 }

