data "template_cloudinit_config" "strongswan_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-strongswan-1
        fqdn: euw2a-prd-unixkingdom-strongswan-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "strongswan-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.strongswan.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-strongswan-1"
  }

  user_data = "${data.template_cloudinit_config.strongswan_config.rendered}"
}

output "strongswan-1" {
  value = "${osc_instance.strongswan-1.private_ip}"
}

resource "osc_security_group" "strongswan" {
  name = "euw2-prd-unixkingdom-strongswan"
  description = "euw2-prd-unixkingdom-strongwan"

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name = "euw2-prd-unixkingdom-strongswan"
  }
}

resource "osc_security_group_rule" "strongswan_zabbix" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.strongswan.id}"
}

resource "osc_security_group_rule" "strongswan_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.strongswan.id}"
}

resource "osc_security_group_rule" "strongswan_icmp" {
  type      = "ingress"
  from_port = -1
  to_port   = -1
  protocol  = "icmp"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.strongswan.id}"
}

resource "osc_security_group_rule" "strongswan_internet" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.strongswan.id}"
}

resource "osc_security_group_rule" "strongswan_ike" {
  type      = "ingress"
  from_port = 500
  to_port   = 500
  protocol  = "udp"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.strongswan.id}"
}

resource "osc_security_group_rule" "strongswan_nat" {
  type      = "egress"
  from_port = 4500
  to_port   = 4500
  protocol  = "udp"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.strongswan.id}"
}
