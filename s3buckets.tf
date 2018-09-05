resource "aws_s3_bucket" "pubkeyStorageBucket" {
  bucket="${lower(local.resource_prefix)}pubkeystore"
  acl = "private"
  lifecycle {
    ignore_changes        = ["tags.tf_created"]
  }
  tags = "${local.common_tags}"
}

resource "aws_s3_bucket_object" "uploadPubkey" {
  count = "${length(var.pubkeyList)}"
  bucket = "${aws_s3_bucket.pubkeyStorageBucket.id}"
  source = "basekeys/${element(var.pubkeyList, count.index)}"
  key = "keys/${element(var.pubkeyList, count.index)}"

  lifecycle {
    ignore_changes        = ["tags.tf_created"]
  }
  tags = "${local.common_tags}"
}
