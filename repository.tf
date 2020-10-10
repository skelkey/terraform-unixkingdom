data "template_cloudinit_config" "repository_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-repository-1
        fqdn: euw2a-prd-unixkingdom-repository-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "repository-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.repository.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-application.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-repository-1"
  }

  user_data = "${data.template_cloudinit_config.repository_config.rendered}"
}

output "repository-1" {
  value = "${osc_instance.repository-1.private_ip}"
}

resource "osc_security_group" "repository" {
  name = "euw2-prd-unixkingdom-repository"
  description = "euw2-prd-unixkingdom-repository"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.lan_subnet}",
    ]

    security_groups = [
      "${osc_security_group.strongswan.id}"
    ]
  }

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

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${osc_security_group.repository-lbu.id}",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    security_groups = [
      "${osc_security_group.repository-lbu.id}",
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
    Name    = "euw2-prd-unixkingdom-repository"
  }
}

resource "osc_elb" "repository-lbu" {
  name            = "euw2-unixkingdom-repository-lbu"

  security_groups = [ "${osc_security_group.repository-lbu.id}" ]
  subnets         = [ "${osc_subnet.euw2-unixkingdom-public.id}" ]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  listener {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  } 

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  tags {
    Name = "euw2a-prd-unixkingdom-repository-lbu"
  }
}

resource "osc_security_group" "repository-lbu" {
  name        = "euw2-prd-unixkingdom-repository-lbu"
  description = "euw2-prd-unixkingdom-repository-lbu"

  ingress = {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress = {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0" ]
  }

  ingress = {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"

    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [ "0.0.0.0/0" ]
  }

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"
}

resource "osc_elb_attachment" "repository-attachment" {
   elb = "${osc_elb.repository-lbu.id}"
   instance = "${osc_instance.repository-1.id}"
} 

