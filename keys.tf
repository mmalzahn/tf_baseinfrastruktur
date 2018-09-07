resource "tls_private_key" "private_key_bastionhost" {
  count     = "${var.aws_key_name == "" ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "privateKeyFile" {
  count    = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_bastionhost.private_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/private.pem"
}

resource "local_file" "publicKeyFile" {
  count    = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_bastionhost.public_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/public.pem"
}

resource "local_file" "publicKeyFileOpenSsh" {
  count    = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_bastionhost.public_key_openssh}"
  filename = "${path.module}/keys/${terraform.workspace}/public_openssh.pub"
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