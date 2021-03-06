data "template_cloudinit_config" "logstash-1_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-logstash-1
        fqdn: euw2a-prd-unixkingdom-logstash-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "logstash-1" {
  ami               = "ami-f929abe8"
  availability_zone = "${var.region}a"
  instance_type     = "tinav4.c2r8p2"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.logstash.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-application.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-logstash-1"
  }

  user_data = "${data.template_cloudinit_config.logstash-1_config.rendered}"
}

output "logstash-1" {
  value = "${osc_instance.logstash-1.private_ip}"
}

resource "osc_security_group" "logstash" {
  name = "euw2-prd-unixkingdom-logstash"
  description = "euw2-prd-unixkingdom-logstash"

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name = "euw2-prd-unixkingdom-logstash"
  }
}

resource "osc_security_group_rule" "logstash_zabbix" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.logstash.id}"
}

resource "osc_security_group_rule" "logstash_ssh_lan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.logstash.id}"
}

resource "osc_security_group_rule" "logstash_ssh_strongswan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.strongswan.id}"
  security_group_id        = "${osc_security_group.logstash.id}"
}


resource "osc_security_group_rule" "logstash_syslog" {
  type      = "ingress"
  from_port = 10514
  to_port   = 10514
  protocol  = "udp"

  cidr_blocks       = [ "172.16.0.0/16" ]
  security_group_id = "${osc_security_group.logstash.id}"
}

resource "osc_security_group_rule" "logstash_beats" {
  type      = "ingress"
  from_port = 5044
  to_port   = 5044
  protocol  = "tcp"

  cidr_blocks       = [ "172.16.0.0/16" ]
  security_group_id = "${osc_security_group.logstash.id}"
}

resource "osc_security_group_rule" "logstash_icmp" {
  type      = "ingress"
  from_port = -1
  to_port   = -1
  protocol  = "icmp"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.logstash.id}"
}

resource "osc_security_group_rule" "logstash_internet" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.logstash.id}"
}
