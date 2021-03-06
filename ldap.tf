resource "osc_instance" "euw2a-prd-unixkingdom-ldap-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.euw2-prd-unixkingdom-ldap.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-storage.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-ldap-1"
  }
}

output "euw2a-prd-unixkingdom-ldap-1" {
  value = "${osc_instance.euw2a-prd-unixkingdom-ldap-1.private_ip}"
}

resource "osc_security_group" "euw2-prd-unixkingdom-ldap" {
  name = "euw2-prd-unixkingdom-ldap" 
  description = "euw2-prd-unixkingdom-ldap"

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name = "euw2-prd-unixkingdom-ldap"
  }
}

resource "osc_security_group_rule" "ldap_zabbix" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

resource "osc_security_group_rule" "ldap_ssh_lan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

resource "osc_security_group_rule" "ldap_ssh_strongswan" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.strongswan.id}"
  security_group_id        = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

resource "osc_security_group_rule" "ldap_icmp" {
  type      = "ingress"
  from_port = -1
  to_port   = -1
  protocol  = "icmp"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

resource "osc_security_group_rule" "ldap_internet" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

resource "osc_security_group_rule" "ldap_ldaps_webadm" {
  type      = "ingress"
  from_port = 636
  to_port   = 636
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.euw2-prd-unixkingdom-webadm.id}"
  security_group_id        = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}


resource "osc_security_group_rule" "ldap_ldaps_radius" {
  type      = "ingress"
  from_port = 636
  to_port   = 636
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.radius.id}"
  security_group_id        = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

resource "osc_security_group_rule" "ldap_ldaps_zabbix" {
  type      = "ingress"
  from_port = 636
  to_port   = 636
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.zabbix.id}"
  security_group_id        = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

resource "osc_security_group_rule" "ldap_ldaps_lan" {
  type      = "ingress"
  from_port = 636
  to_port   = 636
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

resource "osc_security_group_rule" "ldap_ldap_radius" {
  type      = "ingress"
  from_port = 389
  to_port   = 389
  protocol  = "tcp"

  source_security_group_id = "${osc_security_group.radius.id}"
  security_group_id        = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

resource "osc_security_group_rule" "ldap_ldap_lan" {
  type      = "ingress"
  from_port = 389
  to_port   = 389
  protocol  = "tcp"

  cidr_blocks       = [ "${var.lan_subnet}" ]
  security_group_id = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}

