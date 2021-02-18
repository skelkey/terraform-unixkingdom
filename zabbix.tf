data "template_cloudinit_config" "zabbix-1_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-zabbix-1
        fqdn: euw2a-prd-unixkingdom-zabbix-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "zabbix-1" {
  ami               = "ami-f929abe8"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.zabbix.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-public.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-zabbix-1"
    osc.fcu.eip.auto-attach = "${osc_eip.zabbix-1.public_ip}"
  }

  user_data = "${data.template_cloudinit_config.zabbix-1_config.rendered}"
}

output "zabbix-1" {
  value = "${osc_instance.zabbix-1.private_ip}"
}

resource "osc_security_group" "zabbix" {
  name = "euw2-prd-unixkingdom-zabbix"
  description = "euw2-prd-unixkingdom-strongwan"

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name = "euw2-prd-unixkingdom-zabbix"
  }
}

resource "osc_security_group_rule" "zabbix_zabbix" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.zabbix.id}"
}

resource "osc_security_group_rule" "zabbix_ssh_lan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.zabbix.id}"
}

resource "osc_security_group_rule" "zabbix_ssh_strongswan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.strongswan.id}"
  security_group_id        = "${osc_security_group.zabbix.id}"
}

resource "osc_security_group_rule" "zabbix_icmp" {
  type      = "ingress"
  from_port = -1
  to_port   = -1
  protocol  = "icmp"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.zabbix.id}"
}

resource "osc_security_group_rule" "zabbix_internet" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.zabbix.id}"
}

resource "osc_security_group_rule" "zabbix_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.haproxy.id}",
  security_group_id = "${osc_security_group.zabbix.id}"
}

resource "osc_security_group_rule" "zabbix_server_internal" {
  type      = "ingress"
  from_port = 10051
  to_port   = 10051
  protocol  = "tcp"

  cidr_blocks = [ "172.16.0.0/16" ]
  security_group_id = "${osc_security_group.zabbix.id}"
}

resource "osc_security_group_rule" "zabbix_server_external" {
  type      = "ingress"
  from_port = 10051
  to_port   = 10051
  protocol  = "tcp"

  cidr_blocks = "${var.zabbix_proxy_cidr}"
  security_group_id = "${osc_security_group.zabbix.id}"
}

resource "osc_eip" "zabbix-1" {
  vpc = true
}

resource "osc_eip_association" "zabbix-1" {
  instance_id   = "${osc_instance.zabbix-1.id}"
  allocation_id = "${osc_eip.zabbix-1.id}"
}
