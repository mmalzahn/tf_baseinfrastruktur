resource "aws_instance" "bastionhost" {
  count                  = "${var.az_count}"
  ami                    = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type          = "t2.micro"
  subnet_id              = "${element(aws_subnet.DMZ.*.id,count.index)}"
  vpc_security_group_ids = ["${aws_security_group.SG_SSH_IN_from_anywhere.id}"]
  key_name               = "${var.aws_key_name}"
  placement_group        = "${aws_placement_group.pgroup1.name}"
  iam_instance_profile   = "${aws_iam_instance_profile.bastionIamProf.name}"

  #key_name                    = "${aws_key_pair.keypair.key_name}"
  user_data                   = "${data.template_file.bastionhostUserdata.rendered}"
  depends_on                  = ["aws_iam_role.bastionS3pubkeyBucket"]
  associate_public_ip_address = "true"

  lifecycle {
    ignore_changes        = ["tags.tf_created"]
    create_before_destroy = "true"
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "DMZ_Linuxbastionhost_${lookup(local.common_tags,"tf_project")}"
              )
              )}"
}

data "template_file" "bastionhostUserdata" {
  template = "${file("tpl/bastioninstall.tpl")}"

  vars {
    region = "${aws_s3_bucket.pubkeyStorageBucket.region}"
    bucket = "${aws_s3_bucket.pubkeyStorageBucket.id}"
    prefix = "/"
  }
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
  count           = 1
  allow_overwrite = "true"
  depends_on      = ["aws_instance.bastionhost"]
  name            = "bastionhost"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.bastionhost.*.public_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
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
  name               = "BastionIamS3Role-${lookup(local.common_tags,"tf_project_name")}"
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
  key        = "${var.ssh_pubkey_prefix}service-bastionhost-${terraform.workspace}.pub"
  tags       = "${local.common_tags}"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }
}

data "template_file" "awskeyname" {
  template = "${lookup(local.common_tags,"tf_project_name")}_${terraform.workspace}"
}

resource "local_file" "bastionInstallFile" {
  count      = "${var.mm_debug}"
  content    = "${data.template_file.bastionhostUserdata.rendered}"
  filename   = "${path.module}/debug/bastion_userdata.txt"
  depends_on = ["aws_instance.bastionhost"]
}
