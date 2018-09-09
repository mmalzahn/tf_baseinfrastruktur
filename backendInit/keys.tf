resource "tls_private_key" "private_key" {
  count     = "${var.newKeys ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "privateKeyFile" {
  count      = "${var.newKeys ? 1 : 0}"
  content    = "${tls_private_key.private_key.private_key_pem}"
  filename   = "${path.module}/keys/${random_string.userstring.result}.key.pem"
  depends_on = ["tls_private_key.private_key"]
}

resource "local_file" "publicKeyFile" {
  count      = "${var.newKeys ? 1 : 0}"
  content    = "${tls_private_key.private_key.public_key_pem}"
  filename   = "${path.module}/keys/${random_string.userstring.result}.pem"
  depends_on = ["tls_private_key.private_key"]
}

resource "local_file" "publicKeyFileOpenSsh" {
  count      = "${var.newKeys ? 1 : 0}"
  content    = "${tls_private_key.private_key.public_key_openssh}"
  filename   = "${path.module}/keys/${random_string.userstring.result}.pub"
  depends_on = ["tls_private_key.private_key"]
}

resource "aws_key_pair" "keypair" {
  count      = "${var.newKeys ? 1 : 0}"
  key_name   = "${random_string.userstring.result}"
  public_key = "${tls_private_key.private_key.public_key_openssh}"
  depends_on = ["tls_private_key.private_key"]
}
