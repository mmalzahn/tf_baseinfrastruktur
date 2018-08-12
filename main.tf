provider "aws" {
   region = "${var.aws_region}"
   shared_credentials_file = "C:/Users/matthias/.aws/credentials"
   profile = "tfinfrauser"
}
resource "aws_lb" "externerDemoElb" {
  name = "externerDemoElb"
  security_groups = ["${aws_security_group.SG_HTTPS_IN_anywhere.id}"]
  internal = "false"
  subnets = ["${aws_subnet.dmz1.id}","${aws_subnet.dmz2.id}","${aws_subnet.dmz3.id}"]
   tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
   }
}

resource "aws_lb_listener" "demoHTTP" {
  load_balancer_arn = "${aws_lb.externerDemoElb.arn}"
  port = "80"
  protocol = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.TG_Demo_HTTP.arn}"
    type             = "forward"
  }
}
resource "aws_lb_listener" "demoHTTPS" {
  load_balancer_arn = "${aws_lb.externerDemoElb.arn}"
  port = "443"
  protocol = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.TG_Demo_HTTPS.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG_Demo_HTTP" {
  name = "TG-Demo-HTTP"
  port = "81"
  protocol = "TCP"
  proxy_protocol_v2 = "true"
  vpc_id = "${aws_vpc.DemoVPC.id}"
}

resource "aws_lb_target_group" "TG_Demo_HTTPS" {
  name = "TG-Demo-HTTPS"
  port = "444"
  protocol = "TCP"
  proxy_protocol_v2 = "true"
  vpc_id = "${aws_vpc.DemoVPC.id}"
}

resource "aws_lb_target_group" "TG_DCA_HTTPS" {
  name = "TG-DCA-HTTPS"
  port = "445"
  protocol = "TCP"
  proxy_protocol_v2 = "true"
  vpc_id = "${aws_vpc.DemoVPC.id}"
}
