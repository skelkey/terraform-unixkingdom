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

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.lan_subnet}",
    ]

    security_groups = [
      "${osc_security_group.strongswan.id}"
    ]
  }

  ingress {
    from_port = 636
    to_port   = 636
    protocol  = "tcp"

    security_groups = [
      "${osc_security_group.euw2-prd-unixkingdom-webadm.id}",
      "${osc_security_group.radius.id}"
    ]

    cidr_blocks = [
      "${var.lan_subnet}",
    ]
  }

  ingress {
    from_port = 389
    to_port   = 389
    protocol  = "tcp"

    security_groups = [
      "${osc_security_group.radius.id}"
    ]

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags {
    Name = "euw2-prd-unixkingdom-ldap"
  }
}

resource "osc_security_group_rule" "zabbix_ldap" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.euw2-prd-unixkingdom-ldap.id}"
}
