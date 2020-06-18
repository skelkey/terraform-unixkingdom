data "template_cloudinit_config" "keycloak_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-keycloak-1
        fqdn: euw2a-prd-unixkingdom-keycloak-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "keycloak-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.keycloak.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-application.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-keycloak-1"
  }

  user_data = "${data.template_cloudinit_config.keycloak_config.rendered}"
}

output "keycloak-1" {
  value = "${osc_instance.keycloak-1.private_ip}"
}

resource "osc_security_group" "keycloak" {
  name = "euw2-prd-unixkingdom-keycloak"
  description = "euw2-prd-unixkingdom-keycloak"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.lan_subnet}",
    ]

    security_groups = [
      "${osc_security_group.euw2-prd-unixkingdom-strongswan.id}",
    ]
  }

  #ingress {
  #  from_port = 8443
  #  to_port   = 8443
  #  protocol  = "tcp"
  #
  #  security_groups = [
  #    "${osc_security_group.keycloak-lbu.id}",
  #  ]
  #}

  #ingress {
  #  from_port = 80
  #  to_port   = 80
  #  protocol  = "tcp"
  #
  #  security_groups = [
  #    "${osc_security_group.keycloak-lbu.id}",
  #  ]
  #}

  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 4505
    to_port   = 4506
    protocol  = "tcp"

    cidr_blocks = [
      "${osc_instance.euw2a-prd-unixkingdom-saltstack-1.private_ip}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name    = "euw2-prd-unixkingdom-keycloak"
  }
}

#resource "osc_elb" "keycloak-lbu" {
#  name            = "euw2-unixkingdom-keycloak-lbu"
#
#  security_groups = [ "${osc_security_group.keycloak-lbu.id}" ]
#  subnets         = [ "${osc_subnet.euw2-unixkingdom-public.id}" ]
#
#  listener {
#    instance_port     = 80
#    instance_protocol = "HTTP"
#    lb_port           = 80
#    lb_protocol       = "HTTP"
#  }
#
#  listener {
#    instance_port     = 8443
#    instance_protocol = "TCP"
#    lb_port           = 443
#    lb_protocol       = "TCP"
#  } 
#
#  health_check {
#    healthy_threshold   = 2
#    unhealthy_threshold = 2
#    timeout             = 3
#    target              = "TCP:8443"
#    interval            = 30
#  }
#
#  tags {
#    Name = "euw2a-prd-unixkingdom-repository-lbu"
#  }
#}

#resource "osc_security_group" "keycloak-lbu" {
#  name        = "euw2-prd-unixkingdom-keycloak-lbu"
#  description = "euw2-prd-unixkingdom-keycloak-lbu"
#
#  ingress = {
#    from_port = 80
#    to_port   = 80
#    protocol  = "tcp"
#
#    cidr_blocks = [ "0.0.0.0/0" ]
#  }
#
#  ingress = {
#    from_port = 443
#    to_port   = 443
#    protocol  = "tcp"
#
#    cidr_blocks = [
#      "46.231.147.8/32",
#      "78.193.70.43/32",
#    ]
#  }
#
#  ingress = {
#    from_port = -1
#    to_port   = -1
#    protocol  = "icmp"
#
#    cidr_blocks = [ "0.0.0.0/0" ]
#  }
#
#  egress {
#    from_port = 0
#    to_port   = 0
#    protocol  = "-1"
#
#    cidr_blocks = [ "0.0.0.0/0" ]
#  }
#
#  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"
#}

#resource "osc_elb_attachment" "keycloak-attachment" {
#   elb = "${osc_elb.keycloak-lbu.id}"
#   instance = "${osc_instance.keycloak-1.id}"
#} 
