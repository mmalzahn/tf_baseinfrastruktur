resource "aws_api_gateway_rest_api" "getApi" {
  count          = "${var.api_deploy ? 1 : 0}"
  name           = "${local.resource_prefix}getApi"
  api_key_source = "HEADER"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "config_resource" {
  count       = "${var.api_deploy ? 1 : 0}"
  path_part   = "config"
  parent_id   = "${aws_api_gateway_rest_api.getApi.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.getApi.id}"
}

resource "aws_api_gateway_method" "config_method_post" {
  count         = "${var.api_deploy ? 1 : 0}"
  rest_api_id   = "${aws_api_gateway_rest_api.getApi.id}"
  resource_id   = "${aws_api_gateway_resource.config_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "config_method_get" {
  count         = "${var.api_deploy ? 1 : 0}"
  rest_api_id   = "${aws_api_gateway_rest_api.getApi.id}"
  resource_id   = "${aws_api_gateway_resource.config_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "config_post_integration" {
  count                   = "${var.api_deploy ? 1 : 0}"
  rest_api_id             = "${aws_api_gateway_rest_api.getApi.id}"
  resource_id             = "${aws_api_gateway_resource.config_resource.id}"
  http_method             = "${aws_api_gateway_method.config_method_post.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda_set_item.arn}/invocations"
}

resource "aws_api_gateway_integration" "config_get_integration" {
  count                   = "${var.api_deploy ? 1 : 0}"
  rest_api_id             = "${aws_api_gateway_rest_api.getApi.id}"
  resource_id             = "${aws_api_gateway_resource.config_resource.id}"
  http_method             = "${aws_api_gateway_method.config_method_get.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda_get_item.arn}/invocations"
}

resource "aws_api_gateway_deployment" "testdeployment" {
  count       = "${var.api_deploy ? 1 : 0}"
  rest_api_id = "${aws_api_gateway_rest_api.getApi.id}"
  stage_name  = "${terraform.workspace}"

  depends_on = ["aws_api_gateway_integration.config_get_integration",
    "aws_api_gateway_integration.config_get_integration",
  ]
}

resource "aws_api_gateway_domain_name" "tfapidomain" {
  count           = "${var.api_deploy ? 1 : 0}"
  domain_name     = "tfapi.${terraform.workspace}.dca-poc.de"
  certificate_arn = "${data.aws_acm_certificate.cert.arn}"
}

resource "aws_api_gateway_base_path_mapping" "custDomainBasePathMapper" {
  count       = "${var.api_deploy ? 1 : 0}"
  api_id      = "${aws_api_gateway_rest_api.getApi.id}"
  domain_name = "${aws_api_gateway_domain_name.tfapidomain.domain_name}"
  stage_name  = "${aws_api_gateway_deployment.testdeployment.stage_name}"
  base_path   = "v1"
}
