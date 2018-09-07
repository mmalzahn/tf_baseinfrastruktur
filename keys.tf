resource "tls_private_key" "private_key_bastionhost" {
  count     = "${var.aws_key_name == "" ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "privateKeyFile" {
  count    = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_bastionhost.private_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/${random_string.dnshostname.result}.key.pem"
}

resource "local_file" "publicKeyFile" {
  count    = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_bastionhost.public_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/${random_string.dnshostname.result}.pem"
}

resource "local_file" "publicKeyFileOpenSsh" {
  count    = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_bastionhost.public_key_openssh}"
  filename = "${path.module}/keys/${terraform.workspace}/${random_string.dnshostname.result}_openssh.pub"
}

resource "aws_s3_bucket_object" "uploadOwnPubkey" {
  count   = "${var.aws_key_name == "" ? 1 : 0}"
  bucket  = "${aws_s3_bucket.pubkeyStorageBucket.id}"
  content = "${tls_private_key.private_key_bastionhost.public_key_openssh}"
  key     = "keys/${random_string.dnshostname.result}.pub"
  depends_on = ["tls_private_key.private_key_bastionhost"]

  lifecycle {
    ignore_changes = ["tags"]
  }

  tags = "${local.common_tags}"
}

data "template_file" "awskeyname" {
  template = "${local.resource_prefix}${lookup(local.common_tags,"tf_project_name")}"
}

resource "random_string" "dnshostname" {
  length  = 10
  special = false
  upper   = false
  number  = false
}
