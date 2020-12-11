data "template_cloudinit_config" "radius_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-radius-1
        fqdn: euw2a-prd-unixkingdom-radius-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "radius-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.radius.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-application.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-radius-1"
  }

  user_data = "${data.template_cloudinit_config.radius_config.rendered}"
}

output "radius-1" {
  value = "${osc_instance.radius-1.private_ip}"
}

resource "osc_security_group" "radius" {
  name = "euw2-prd-unixkingdom-radius"
  description = "euw2-prd-unixkingdom-radius"

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name    = "euw2-prd-unixkingdom-radius"
  }
}

resource "osc_security_group_rule" "radius_zabbix" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.radius.id}"
}

resource "osc_security_group_rule" "radius_ssh_lan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.radius.id}"
}

resource "osc_security_group_rule" "radius_ssh_strongswan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.strongswan.id}"
  security_group_id        = "${osc_security_group.radius.id}"
}

resource "osc_security_group_rule" "radius_icmp" {
  type      = "ingress"
  from_port = -1
  to_port   = -1
  protocol  = "icmp"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.radius.id}"
}

resource "osc_security_group_rule" "radius_internet" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.radius.id}"
}
