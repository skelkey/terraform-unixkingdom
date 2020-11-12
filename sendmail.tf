data "template_cloudinit_config" "sendmail-1_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-sendmail-1
        fqdn: euw2a-prd-unixkingdom-sendmail-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "sendmail-1" {
  ami               = "ami-f929abe8"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.sendmail.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-sendmail-1"
  }

  user_data = "${data.template_cloudinit_config.sendmail-1_config.rendered}"
}

output "sendmail-1" {
  value = "${osc_instance.sendmail-1.private_ip}"
}

resource "osc_security_group" "sendmail" {
  name = "euw2-prd-unixkingdom-sendmail"
  description = "euw2-prd-unixkingdom-sendmail"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.lan_subnet}",
    ]

    security_groups = [
      "${osc_security_group.strongswan.id}",
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
    from_port = 465
    to_port   = 465
    protocol  = "tcp"

    security_groups = [
      "${osc_security_group.passbolt.id}"
    ]
  }

  ingress {
    from_port = 587
    to_port   = 587
    protocol  = "tcp"

    security_groups = [
      "${osc_security_group.passbolt.id}"
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
    Name    = "euw2-prd-unixkingdom-sendmail"
  }
}
