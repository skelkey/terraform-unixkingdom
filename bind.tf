resource "osc_instance" "euw2a-prd-unixkingdom-bind-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"
  private_ip        = "172.16.4.69"

  vpc_security_group_ids = [
    "${osc_security_group.euw2-prd-unixkingdom-bind.id}"
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-bind-1"
  }
}

output "euw2a-prd-unixkingdom-bind-1" {
  value = "${osc_instance.euw2a-prd-unixkingdom-bind-1.private_ip}"
}

resource "osc_instance" "euw2a-prd-unixkingdom-bind-2" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"
  private_ip        = "172.16.4.70"

  vpc_security_group_ids = [
    "${osc_security_group.euw2-prd-unixkingdom-bind.id}"
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2a-prd-unixkingdom-bind-2"
  }
}

output "euw2a-prd-unixkingdom-bind-2" {
  value = "${osc_instance.euw2a-prd-unixkingdom-bind-2.private_ip}"
}

resource "osc_security_group" "euw2-prd-unixkingdom-bind" {
  name = "euw2-prd-unixkingdom-bind"
  description = "euw2-prd-unixkingdom-bind"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.lan_subnet}",
    ]
  }

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"

    cidr_blocks = [
      "0.0.0.0/0"
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
    Name = "euw2-prd-unixkingdom-bind"
  }
}
