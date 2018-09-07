resource "aws_instance" "bastionhost" {
  count                                = "${var.optimal_design ? var.az_count : 1}"
  ami                                  = "${data.aws_ami.bastionhostPackerAmi.id}"
  instance_type                        = "t2.micro"
  subnet_id                            = "${element(aws_subnet.DMZ.*.id,count.index)}"
  vpc_security_group_ids               = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
  placement_group                      = "${aws_placement_group.bastionhostpgroup.id}"
  iam_instance_profile                 = "${aws_iam_instance_profile.bastionIamProf.name}"
  instance_initiated_shutdown_behavior = "terminate"
  user_data                            = "${data.template_file.bastionhostUserdata.rendered}"
  associate_public_ip_address          = "true"
  volume_tags                          = "${local.common_tags}"
  key_name                             = "${var.debug_on ? var.aws_key_name : ""}"

  depends_on = [
    "aws_iam_role.bastionhostRole",
    "aws_subnet.DMZ",
  ]

  lifecycle {
    ignore_changes        = ["tags.tf_created", "volume_tags.tf_created"]
    create_before_destroy = "true"
  }
  volume_tags = "${merge(local.common_tags,
            map(
              "belongs_to", "${local.resource_prefix}DMZ_Linuxbastionhost_${count.index + 1}_${lookup(local.common_tags,"tf_project")}"
              )
              )}"

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}DMZ_Linuxbastionhost_${count.index + 1}_${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_placement_group" "bastionhostpgroup" {
  name     = "${local.resource_prefix}bastionhost-pgroup"
  strategy = "spread"
}

data "template_file" "bastionhostUserdata" {
  template = "${file("tpl/bastioninstall.tpl")}"

  vars {
    region    = "${aws_s3_bucket.pubkeyStorageBucket.region}"
    bucket    = "${aws_s3_bucket.pubkeyStorageBucket.id}"
    prefix    = "keys/"
    topic_arn = "${local.adminInfoTopic}"
  }
}

resource "aws_security_group" "SG_SSH_IN_from_anywhere" {
  name        = "${local.resource_prefix}SG_SSH_IN_from_anywhere_${lookup(local.common_tags,"tf_project_name")}"
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
              "Name", "${local.resource_prefix}SG_SSH_IN_from_anywhere__${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_route53_record" "bastionhostdns" {
  count           = "${var.optimal_design ? var.az_count : 1}"
  allow_overwrite = "true"
  depends_on      = ["aws_instance.bastionhost"]
  name            = "bastion-${count.index + 1}.${terraform.workspace}"
  type            = "A"
  ttl             = 60
  records         = ["${element(aws_instance.bastionhost.*.public_ip, count.index)}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "bastionhostdnsdirekt" {
  count           = "${var.optimal_design ? 0 : 1}"
  allow_overwrite = "true"
  depends_on      = ["aws_instance.bastionhost"]
  name            = "bastionhost.${terraform.workspace}"
  type            = "A"
  ttl             = 60
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
  records         = ["${element(aws_instance.bastionhost.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "bastionhostalias" {
  count           = "${var.optimal_design ? 1 : 0}"
  allow_overwrite = "true"
  depends_on      = ["aws_lb.bastionLb"]

  name    = "bastionhost.${terraform.workspace}"
  ttl     = 60
  type    = "CNAME"
  records = ["${aws_lb.bastionLb.dns_name}"]
  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

data "template_file" "iampolicy_s3" {
  template = "${file("tpl/iampol_s3.tpl")}"

  vars {
    bucket = "${aws_s3_bucket.pubkeyStorageBucket.id}"
  }
}
data "template_file" "iampolicy_sns" {
  template = "${file("tpl/iampol_sns.tpl")}"

  vars {
    target_topic = "${data.dns_txt_record_set.infotopic.record}"
  }
}

resource "aws_iam_instance_profile" "bastionIamProf" {
  name = "bastionIamProf_${lookup(local.common_tags,"tf_project_name")}_${terraform.workspace}"
  role = "${aws_iam_role.bastionhostRole.name}"
}

resource "aws_iam_role" "bastionhostRole" {
  name               = "${local.resource_prefix}BastionIamRole"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_role_policy" "bastionIamS3BucketPol" {
  name   = "s3BucketPol"
  policy = "${data.template_file.iampolicy_s3.rendered}"
  role   = "${aws_iam_role.bastionhostRole.id}"
}
resource "aws_iam_role_policy" "bastionIamSnsTopicPol" {
  name   = "snsTopicPol"
  policy = "${data.template_file.iampolicy_sns.rendered}"
  role   = "${aws_iam_role.bastionhostRole.id}"
}

resource "aws_lb" "bastionLb" {
  count              = "${var.optimal_design ? 1 : 0}"
  name               = "${local.resource_prefix}BastionLb"
  internal           = "false"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.DMZ.*.id}"]

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${local.common_tags}"
}

resource "aws_lb_listener" "ssh" {
  count             = "${var.optimal_design ? 1 : 0}"
  load_balancer_arn = "${aws_lb.bastionLb.arn}"
  port              = "22"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.bastionhostLB.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "bastionhostLB" {
  count             = "${var.optimal_design ? 1 : 0}"
  name              = "${local.resource_prefix}bastionhost"
  port              = 22
  protocol          = "TCP"
  proxy_protocol_v2 = false
  target_type       = "instance"
  vpc_id            = "${aws_vpc.mainvpc.id}"
}

resource "aws_lb_target_group_attachment" "addBastionhostToTg" {
  count            = "${var.optimal_design ? var.az_count : 0}"
  target_id        = "${element(aws_instance.bastionhost.*.id,count.index)}"
  port             = 22
  target_group_arn = "${aws_lb_target_group.bastionhostLB.arn}"
}
