resource "osc_instance" "euw2a-prd-unixkingdom-mariadb-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.euw2-prd-unixkingdom-mariadb.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-storage.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-mariadb-1"
  }
}

output "euw2a-prd-unixkingdom-mariadb-1" {
  value = "${osc_instance.euw2a-prd-unixkingdom-mariadb-1.private_ip}"
}

resource "osc_security_group" "euw2-prd-unixkingdom-mariadb" {
  name = "euw2-prd-unixkingdom-mariadb"
  description = "euw2-prd-unixkingdom-mariadb"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.lan_subnet}",
    ]
  }

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    cidr_blocks = [
      "${osc_instance.euw2a-prd-unixkingdom-ejbca-1.private_ip}",
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
