provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "C:/Users/matthias/.aws/credentials"
  profile                 = "tfinfrauser"
}

terraform {
  backend "s3" {
    bucket         = "mm-terraform-remote-state-storage"
    key            = "selfinfra.state"
    dynamodb_table = "mm-terraform-state-lock-dynamo"
    region         = "eu-west-1"
  }
}

resource "aws_lb" "externerDemoElb" {
  name               = "externerDemoElb"
  internal           = "false"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.DMZ.*.id}"]

  tags = "${local.common_tags}"
}

resource "aws_lb_listener" "demoHTTPS" {
  load_balancer_arn = "${aws_lb.externerDemoElb.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.TG_Demo_HTTPS.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG_Demo_HTTPS" {
  name              = "TG-Demo-HTTPS"
  port              = "444"
  protocol          = "TCP"
  proxy_protocol_v2 = "true"
  target_type       = "instance"
  vpc_id            = "${aws_vpc.DemoVPC.id}"
  tags              = "${local.common_tags}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_demoHTTPS" {
  target_id        = "${aws_instance.nginx_DMZ.id}"
  port             = 444
  target_group_arn = "${aws_lb_target_group.TG_Demo_HTTPS.arn}"
}

resource "aws_lb" "externerDCAElb" {
  name               = "externerDCAElb"
  internal           = "false"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.DMZ.*.id}"]
  tags               = "${local.common_tags}"
}

resource "aws_lb_listener" "dcaHTTP" {
  load_balancer_arn = "${aws_lb.externerDCAElb.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.TG_DCA_HTTP.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "dcaHTTPS" {
  load_balancer_arn = "${aws_lb.externerDCAElb.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.TG_DCA_HTTPS.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG_DCA_HTTP" {
  name              = "TG-DCA-HTTP"
  port              = "81"
  protocol          = "TCP"
  proxy_protocol_v2 = "true"
  target_type       = "instance"
  vpc_id            = "${aws_vpc.DemoVPC.id}"
  tags              = "${local.common_tags}"
}

resource "aws_lb_target_group" "TG_DCA_HTTPS" {
  name              = "TG-DCA-HTTPS"
  port              = "445"
  protocol          = "TCP"
  proxy_protocol_v2 = "true"
  target_type       = "instance"
  vpc_id            = "${aws_vpc.DemoVPC.id}"
  tags              = "${local.common_tags}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_dcaHTTPS" {
  target_id        = "${aws_instance.nginx_DMZ.id}"
  port             = 445
  target_group_arn = "${aws_lb_target_group.TG_DCA_HTTPS.arn}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_dcaHTTP" {
  target_id        = "${aws_instance.nginx_DMZ.id}"
  port             = 81
  target_group_arn = "${aws_lb_target_group.TG_DCA_HTTP.arn}"
}

resource "aws_route53_record" "dca_jumphost" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.jumphost_DMZ"]
  name            = "jumphost"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.jumphost_DMZ.public_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "dca_dmzProxy" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.nginx_DMZ"]
  name            = "dmzproxy"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.nginx_DMZ.public_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "dca_dmzProxyIntern" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.nginx_DMZ"]
  name            = "dmzproxyintern"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.nginx_DMZ.private_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "elb_demo_extern" {
  allow_overwrite = "true"
  depends_on      = ["aws_lb.externerDemoElb"]
  name            = "elbdemoextern"
  ttl             = "60"
  type            = "CNAME"
  records         = ["${aws_lb.externerDemoElb.dns_name}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

data "aws_route53_zone" "dca_poc_domain" {
  name = "dca-poc.de."
}

data "aws_route53_zone" "dca_internal_domain" {
  name         = "dca.internal."
  private_zone = "true"
}
