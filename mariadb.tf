data "template_cloudinit_config" "mariadb-1_config" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.minion.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
        preserve_hostname: false
        hostname: euw2a-prd-unixkingdom-mariadb-1
        fqdn: euw2a-prd-unixkingdom-mariadb-1
        manage_etc_hosts: true
    EOF
  }
}

resource "osc_instance" "mariadb-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.mariadb.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-storage.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-mariadb-1"
  }

  user_data = "${data.template_cloudinit_config.mariadb-1_config.rendered}"
}

output "mariadb-1" {
  value = "${osc_instance.mariadb-1.private_ip}"
}

resource "osc_security_group" "mariadb" {
  name = "euw2-prd-unixkingdom-mariadb"
  description = "euw2-prd-unixkingdom-mariadb"

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
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [
      "${osc_security_group.euw2-prd-unixkingdom-webadm.id}",
      "${osc_security_group.zabbix.id}"
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
    Name    = "euw2-prd-unixkingdom-mariadb"
  }
}

resource "osc_security_group_rule" "zabbix_mariadb" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.euw2-prd-unixkingdom-webadm.id}"
}
