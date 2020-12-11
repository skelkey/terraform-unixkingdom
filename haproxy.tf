data "template_cloudinit_config" "haproxy_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-haproxy-1
        fqdn: euw2a-prd-unixkingdom-haproxy-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "haproxy-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.haproxy.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-haproxy-1"
  }

  user_data = "${data.template_cloudinit_config.haproxy_config.rendered}"
}

output "haproxy-1" {
  value = "${osc_instance.haproxy-1.private_ip}"
}

resource "osc_security_group" "haproxy" {
  name = "euw2-prd-unixkingdom-haproxy"
  description = "euw2-prd-unixkingdom-haproxy"

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name    = "euw2-prd-unixkingdom-haproxy"
  }
}

resource "osc_security_group_rule" "haproxy_zabbix" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.haproxy.id}"
}

resource "osc_security_group_rule" "haproxy_ssh_lan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.haproxy.id}"
}

resource "osc_security_group_rule" "haproxy_ssh_strongswan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.strongswan.id}"
  security_group_id        = "${osc_security_group.haproxy.id}"
}

resource "osc_security_group_rule" "haproxy_icmp" {
  type      = "ingress"
  from_port = -1
  to_port   = -1
  protocol  = "icmp"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.haproxy.id}"
}

resource "osc_security_group_rule" "haproxy_internet" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.haproxy.id}"
}

resource "osc_security_group_rule" "haproxy_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.haproxy.id}"
}

resource "osc_security_group_rule" "haproxy_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.haproxy.id}"
}

