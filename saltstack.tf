resource "osc_instance" "euw2a-prd-unixkingdom-saltstack-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.euw2-prd-unixkingdom-saltstack.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-saltstack-1"
  }
}

output "euw2a-prd-unixkingdom-saltstack-1" {
  value = "${osc_instance.euw2a-prd-unixkingdom-saltstack-1.private_ip}"
}

resource "osc_security_group" "euw2-prd-unixkingdom-saltstack" {
  name = "euw2-prd-unixkingdom-saltstack"
  description = "euw2-prd-unixkingdom-saltstack"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

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

  ingress {
    from_port = 4505
    to_port   = 4506
    protocol  = "tcp"

    cidr_blocks = [
      "172.16.0.0/16",
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
    Name    = "euw2-prd-unixkingdom-saltstack"
  }
}

resource "osc_security_group_rule" "zabbix_saltstack" {
  type      = "ingress"
  from_port = 10050
  to_port   = 10050
  protocol  = "tcp"

  source_security_group_id   = "${osc_security_group.zabbix.id}"
  security_group_id          = "${osc_security_group.euw2-prd-unixkingdom-saltstack.id}"
}
