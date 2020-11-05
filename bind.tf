data "template_cloudinit_config" "bind-1_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-bind-1
        fqdn: euw2a-prd-unixkingdom-bind-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "bind-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"
  private_ip        = "172.16.4.69"

  vpc_security_group_ids = [
    "${osc_security_group.bind.id}"
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-bind-1"
  }

  user_data = "${data.template_cloudinit_config.bind-1_config.rendered}"
}

output "bind-1" {
  value = "${osc_instance.bind-1.private_ip}"
}

data "template_cloudinit_config" "bind-2_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-bind-2
        fqdn: euw2a-prd-unixkingdom-bind-2
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "bind-2" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"
  private_ip        = "172.16.4.70"

  vpc_security_group_ids = [
    "${osc_security_group.bind.id}"
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-bind-2"
  }

  user_data = "${data.template_cloudinit_config.bind-2_config.rendered}"
}

output "bind-2" {
  value = "${osc_instance.bind-2.private_ip}"
}

resource "osc_security_group" "bind" {
  name = "euw2-prd-unixkingdom-bind"
  description = "euw2-prd-unixkingdom-bind"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.lan_subnet}",
    ]
  }

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"

    cidr_blocks = [
      "0.0.0.0/0"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name = "euw2-prd-unixkingdom-bind"
  }
}
