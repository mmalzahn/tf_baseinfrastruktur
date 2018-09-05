# resource "null_resource" "buildBastionAmi" {
# triggers {
#     bastion_hosts = "${join(",", aws_subnet.DMZ.*.id)}"
#   }
#   provisioner "local-exec" {
#     command = "packer build -var 'responsible=${var.tag_responsibel}' -var 'project=${var.project_name}' -var 'projectprefix=${local.resource_prefix}' -var 'jsonfile=bastionhost.json' -var 'workdir =${path.cwd}/packer/' -var 'packerId=bastionhost' ./packer/bastionhost.json"
#     interpreter = ["PowerShell", "-Command"]
#   }
# }

resource "aws_instance" "bastionhost" {
  count                  = "${var.optimal_design ? var.az_count : 1}"
  ami                    = "${data.aws_ami.bastionhostPackerAmi.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${element(aws_subnet.DMZ.*.id,count.index)}"
  vpc_security_group_ids = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
  #key_name               = "${var.aws_key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.bastionIamProf.name}"
  user_data              = "${data.template_file.bastionhostUserdata.rendered}"

  depends_on = [
    "aws_iam_role.bastionS3pubkeyBucket",
    "aws_subnet.DMZ",
  ]

  associate_public_ip_address = "true"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
    create_before_destroy = "true"
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}DMZ_Linuxbastionhost_${count.index + 1}_${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

resource "aws_placement_group" "pgroup1" {
  name     = "${local.resource_prefix}pgroup1"
  strategy = "spread"
}

data "template_file" "bastionhostUserdata" {
  template = "${file("tpl/bastioninstall.tpl")}"

  vars {
    region = "${aws_s3_bucket.pubkeyStorageBucket.region}"
    bucket = "${aws_s3_bucket.pubkeyStorageBucket.id}"
    prefix = "keys/"
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

data "template_file" "iampolicy" {
  template = "${file("tpl/iampol.tpl")}"

  vars {
    bucket = "${aws_s3_bucket.pubkeyStorageBucket.id}"
  }
}

resource "aws_iam_instance_profile" "bastionIamProf" {
  name = "bastionIamProf_${lookup(local.common_tags,"tf_project_name")}_${terraform.workspace}"
  role = "${aws_iam_role.bastionS3pubkeyBucket.name}"
}

resource "aws_iam_role" "bastionS3pubkeyBucket" {
  name               = "${local.resource_prefix}BastionIamS3Role}"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_role_policy" "bastionIamS3BucketPol" {
  name   = "s3BucketPol"
  policy = "${data.template_file.iampolicy.rendered}"
  role   = "${aws_iam_role.bastionS3pubkeyBucket.id}"
}

resource "tls_private_key" "private_key_bastionhost" {
  count     = "${var.aws_key_name == "" ? 1 : 0}"
  algorithm = "RSA"
}

resource "local_file" "privateKeyFile" {
  count    = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_bastionhost.private_key_pem}"
  filename = "${path.module}/keys/private.pem"
}

resource "local_file" "publicKeyFile" {
  count    = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_bastionhost.public_key_pem}"
  filename = "${path.module}/keys/public.pem"
}

resource "local_file" "publicKeyFileOpenSsh" {
  count    = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_bastionhost.public_key_openssh}"
  filename = "${path.module}/keys/public_openssh.pub"
}

resource "aws_s3_bucket_object" "uploadPubKey" {
  count      = "${var.aws_key_name == "" ? 1 : 0}"
  bucket     = "${var.ssh_pubkey_bucket}"
  content    = "${tls_private_key.private_key_bastionhost.public_key_openssh}"
  depends_on = ["tls_private_key.private_key_bastionhost"]
  key        = "${var.ssh_pubkey_prefix}${local.resource_prefix}bastionhost-${random_id.configId.b64_url}.pub"
  tags       = "${local.common_tags}"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }
}

data "template_file" "awskeyname" {
  template = "${local.resource_prefix}${lookup(local.common_tags,"tf_project_name")}"
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
