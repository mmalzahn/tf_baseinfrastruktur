resource "aws_api_gateway_rest_api" "getApi" {
  count          = "${var.api_deploy ? 1 : 0}"
  name           = "${local.resource_prefix}getApi"
  api_key_source = "HEADER"

  depends_on = [
    "aws_lambda_function.lambda_get_item",
    "aws_lambda_function.lambda_set_item",
  ]

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

resource "aws_lambda_permission" "apigw_configGet_lambda" {
  count         = "${var.api_deploy ? 1 : 0}"
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_get_item.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_accountId}:${aws_api_gateway_rest_api.getApi.id}/*/${aws_api_gateway_method.config_method_get.http_method}${aws_api_gateway_resource.config_resource.path}"
}

resource "aws_lambda_permission" "apigw_configPost_lambda" {
  count         = "${var.api_deploy ? 1 : 0}"
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_set_item.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_accountId}:${aws_api_gateway_rest_api.getApi.id}/*/${aws_api_gateway_method.config_method_post.http_method}${aws_api_gateway_resource.config_resource.path}"
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

  depends_on = [
    "aws_api_gateway_integration.config_get_integration",
    "aws_api_gateway_integration.config_post_integration",
  ]
}

resource "aws_api_gateway_domain_name" "tfapidomain_workspace" {
  count           = "${var.api_deploy ? 1 : 0}"
  domain_name     = "${var.api_deploy_dns}.${terraform.workspace}.dca-poc.de"
  certificate_arn = "${data.aws_acm_certificate.cert_dev.arn}"
}

resource "aws_api_gateway_domain_name" "tfapidomain_base" {
  count           = "${var.api_deploy ? terraform.workspace == "prod" ? 1: 0 : 0}"
  domain_name     = "dev.dca-poc.de"
  certificate_arn = "${data.aws_acm_certificate.cert_base.arn}"
}

resource "aws_api_gateway_base_path_mapping" "custDomainBasePathMapper_dev" {
  count       = "${var.api_deploy ? 1 : 0}"
  api_id      = "${aws_api_gateway_rest_api.getApi.id}"
  domain_name = "${aws_api_gateway_domain_name.tfapidomain_workspace.domain_name}"
  stage_name  = "${aws_api_gateway_deployment.testdeployment.stage_name}"
  base_path   = "v1"
}

resource "aws_api_gateway_base_path_mapping" "custDomainBasePathMapper_base" {
  count       = "${var.api_deploy ? terraform.workspace == "prod" ? 1: 0 : 0}"
  api_id      = "${aws_api_gateway_rest_api.getApi.id}"
  domain_name = "${aws_api_gateway_domain_name.tfapidomain_base.domain_name}"
  stage_name  = "${aws_api_gateway_deployment.testdeployment.stage_name}"
  base_path   = "v1"
}

resource "aws_route53_record" "apidns_base" {
  count           = "${var.api_deploy ? terraform.workspace == "prod" ? 1: 0 : 0}"
  allow_overwrite = "true"
  depends_on      = ["aws_api_gateway_deployment.testdeployment"]
  name            = "${aws_api_gateway_domain_name.tfapidomain_base.domain_name}"
  type            = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.tfapidomain_base.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.tfapidomain_base.cloudfront_zone_id}"
    evaluate_target_health = true
  }

  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "apidns_workspace" {
  count           = "${var.api_deploy ?  1:  0}"
  allow_overwrite = "true"
  depends_on      = ["aws_api_gateway_deployment.testdeployment"]
  name            = "${aws_api_gateway_domain_name.tfapidomain_workspace.domain_name}"
  type            = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.tfapidomain_workspace.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.tfapidomain_workspace.cloudfront_zone_id}"
    evaluate_target_health = true
  }

  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
