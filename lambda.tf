provider "archive" {}

data "archive_file" "zip_config_get" {
  count = "${var.api_deploy ? 1 : 0}"
  type        = "zip"
  source_file = "lambda/configGet.py"
  output_path = "tmp/configGet.zip"
}

data "archive_file" "zip_config_post" {
  count = "${var.api_deploy ? 1 : 0}"
  type        = "zip"
  source_file = "lambda/configPost.py"
  output_path = "tmp/configPost.zip"
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_dynamodb_table" "tf_config_table" {
  count = "${var.api_deploy ? 1 : 0}"
  name           = "${local.resource_prefix}configTable"
  read_capacity  = 20
  write_capacity = 10
  hash_key       = "ConfigId"
  stream_enabled = "false"
  tags           = "${local.common_tags}"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  attribute {
    name = "ConfigId"
    type = "S"
  }
}

resource "aws_iam_role" "iam_for_lambda_post" {
  count = "${var.api_deploy ? 1 : 0}"
  name               = "${local.resource_prefix}lambdaConfigPost"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_iam_role" "iam_for_lambda_get" {
  count = "${var.api_deploy ? 1 : 0}"
  name               = "${local.resource_prefix}lambdaConfigGet"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_iam_role_policy" "dynamodbgetitem" {
  count = "${var.api_deploy ? 1 : 0}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "dynamodb:GetItem",
            "Resource": "${aws_dynamodb_table.tf_config_table.arn}"
        }
    ]
}
EOF

  role = "${aws_iam_role.iam_for_lambda_get.id}"
}

resource "aws_iam_role_policy" "dynamodbsetitem" {
  count = "${var.api_deploy ? 1 : 0}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "${aws_dynamodb_table.tf_config_table.arn}"
        }
    ]
}
EOF

  role = "${aws_iam_role.iam_for_lambda_post.id}"
}

resource "aws_lambda_function" "lambda_get_item" {
  count = "${var.api_deploy ? 1 : 0}"
  function_name    = "${local.resource_prefix}get_tf_config_lambda"
  filename         = "${data.archive_file.zip_config_get.output_path}"
  source_code_hash = "${data.archive_file.zip_config_get.output_sha}"
  role             = "${aws_iam_role.iam_for_lambda_get.arn}"
  handler          = "confgiGet.lambda_handler"
  runtime          = "python3.6"
  tags             = "${local.common_tags}"

  lifecycle {
    ignore_changes = [
      "tags.tf_created",
      "last_modified",
      "source_code_hash",
    ]
  }

  environment {
    variables = {
      greeting = "Hello"
    }
  }
}

resource "aws_lambda_function" "lambda_set_item" {
  count = "${var.api_deploy ? 1 : 0}"
  function_name    = "${local.resource_prefix}post_tf_config_lambda"
  filename         = "${data.archive_file.zip_config_post.output_path}"
  source_code_hash = "${data.archive_file.zip_config_post.output_sha}"
  role             = "${aws_iam_role.iam_for_lambda_post.arn}"
  handler          = "confgiPost.lambda_handler"
  runtime          = "python3.6"
  tags             = "${local.common_tags}"

  lifecycle {
    ignore_changes = [
      "tags.tf_created",
      "last_modified",
      "source_code_hash",
    ]
  }

  environment {
    variables = {
      greeting = "Hello"
    }
  }
}
