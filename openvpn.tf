data "template_cloudinit_config" "openvpn_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-openvpn-1
        fqdn: euw2a-prd-unixkingdom-openvpn-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "openvpn-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.openvpn.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-openvpn-1"
  }

  user_data = "${data.template_cloudinit_config.waproxy_config.rendered}"
}

output "openvpn-1" {
  value = "${osc_instance.openvpn-1.private_ip}"
}

resource "osc_security_group" "openvpn" {
  name = "euw2-prd-unixkingdom-openvpn"
  description = "euw2-prd-unixkingdom-openvpn"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    ##
    # FIXME: REMOVE ILLEGITIMATE PUBLIC IP
    ##
    cidr_blocks = [
        "${var.lan_subnet}",
        "171.33.74.198/32",
        "46.231.144.177/32",
        "78.193.70.43/32",
        "78.219.120.92/32",
        "46.231.147.8/32",
        "88.121.69.139/32",
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
    from_port = 1194
    to_port   = 1194
    protocol  = "udp"

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
    Name = "euw2-prd-unixkingdom-openvpn"
  }
}
