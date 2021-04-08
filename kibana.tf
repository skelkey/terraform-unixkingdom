data "template_cloudinit_config" "kibana-1_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-kibana-1
        fqdn: euw2a-prd-unixkingdom-kibana-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "kibana-1" {
  ami               = "ami-f929abe8"
  availability_zone = "${var.region}a"
  instance_type     = "tinav4.c2r8p2"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.kibana.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-application.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-kibana-1"
  }

  user_data = "${data.template_cloudinit_config.kibana-1_config.rendered}"
}

output "kibana-1" {
  value = "${osc_instance.kibana-1.private_ip}"
}

resource "osc_security_group" "kibana" {
  name = "euw2-prd-unixkingdom-kibana"
  description = "euw2-prd-unixkingdom-kibana"

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name = "euw2-prd-unixkingdom-kibana"
  }
}

resource "osc_security_group_rule" "kibana_zabbix" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.kibana.id}"
}

resource "osc_security_group_rule" "kibana_ssh_lan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.kibana.id}"
}

resource "osc_security_group_rule" "kibana_ssh_strongswan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.strongswan.id}"
  security_group_id        = "${osc_security_group.kibana.id}"
}

resource "osc_security_group_rule" "kibana_https" {
  type      = "ingress"
  from_port = 5601
  to_port   = 5601
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.haproxy.id}",
  security_group_id = "${osc_security_group.kibana.id}"
}

resource "osc_security_group_rule" "kibana_icmp" {
  type      = "ingress"
  from_port = -1
  to_port   = -1
  protocol  = "icmp"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.kibana.id}"
}

resource "osc_security_group_rule" "kibana_internet" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.kibana.id}"
}
