data "template_cloudinit_config" "bitwarden_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-bitwarden-1
        fqdn: euw2a-prd-unixkingdom-bitwarden-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "bitwarden-1" {
  ami               = "ami-f929abe8"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.bitwarden.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-bitwarden-1"
  }

  user_data = "${data.template_cloudinit_config.bitwarden_config.rendered}"
}

output "bitwarden-1" {
  value = "${osc_instance.bitwarden-1.private_ip}"
}

resource "osc_security_group" "bitwarden" {
  name = "euw2-prd-unixkingdom-bitwarden"
  description = "euw2-prd-unixkingdom-strongwan"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
        "${var.lan_subnet}",
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
    from_port = 500
    to_port   = 500
    protocol  = "udp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 4500
    to_port   = 4500
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
    Name = "euw2-prd-unixkingdom-bitwarden"
  }
}
