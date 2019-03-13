resource "osc_vpc" "euw2-unixkingdom-network" {
  cidr_block = "172.16.0.0/16"

  tags {
    Name = "euw2-unixkingdom-network"
  }
}

resource "osc_subnet" "euw2-unixkingdom-public" {
  vpc_id            = "${osc_vpc.euw2-unixkingdom-network.id}"
  cidr_block        = "172.16.1.0/24"
  availability_zone = "${var.region}a"

  tags {
    Name    = "euw2-unixkingdom-public"
  }
}

resource "osc_subnet" "euw2-unixkingdom-application" {
  vpc_id            = "${osc_vpc.euw2-unixkingdom-network.id}"
  cidr_block        = "172.16.2.0/24"
  availability_zone = "${var.region}a"

  tags {
    Name    = "euw2-unixkingdom-application"
  }
}

resource "osc_subnet" "euw2-unixkingdom-storage" {
  vpc_id            = "${osc_vpc.euw2-unixkingdom-network.id}"
  cidr_block        = "172.16.3.0/24"
  availability_zone = "${var.region}a"

  tags {
    Name    = "euw2-unixkingdom-storage"
  }
}

resource "osc_customer_gateway" "euw2-unixkingdom-cgw-paris15" {
  bgp_asn    = 65000
  ip_address = "82.254.168.142"
  type       = "ipsec.1"

  tags {
    Name    = "euw2-unixkingdom-cgw-paris15"
  }
}

resource "osc_vpn_gateway" "euw2-unixkingdom-vgw" {
  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"
  tags {
    Name    = "euw2-unixkingdom-vgw"
  }
}

resource "osc_vpn_connection" "euw2-unixkingdom-vpn-paris15" {
  vpn_gateway_id      = "${osc_vpn_gateway.euw2-unixkingdom-vgw.id}"
  customer_gateway_id = "${osc_customer_gateway.euw2-unixkingdom-cgw-paris15.id}"
  type                = "ipsec.1"
  static_routes_only  = false
}

resource "osc_security_group" "euw2-prd-unixkingdom-saltstack" {
  name = "euw2-prd-unixkingdom-saltstack"
  description = "euw2-prd-unixkingdom-saltstack"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.2.0/24",
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
    Name    = "euw2-prd-unixkingdom-saltstack"
  }
}

resource "osc_route_table" "euw2-paris15-lan" {
  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  route {
    cidr_block = "192.168.2.0/24"
    gateway_id = "${osc_vpn_gateway.euw2-unixkingdom-vgw.id}"
  }
}

resource "osc_route_table_association" "euw2-paris15-lan" {
  subnet_id      = "${osc_subnet.euw2-unixkingdom-application.id}"
  route_table_id = "${osc_route_table.euw2-paris15-lan.id}"
}
