resource "osc_vpc" "euw2-unixkingdom-network" {
  cidr_block = "172.16.0.0/16"

  tags {
    Name = "euw2-unixkingdom-network"
  }
}

resource "osc_vpc_dhcp_options" "euw2-unixkingdom-dnsresolver" {
  domain_name_servers = [ "172.16.4.69", "172.16.4.70" ]
}

resource "osc_vpc_dhcp_options_association" "euw2-unixkingdom-dhcpopt" {
  vpc_id          = "${osc_vpc.euw2-unixkingdom-network.id}"
  dhcp_options_id = "${osc_vpc_dhcp_options.euw2-unixkingdom-dnsresolver.id}"
}

resource "osc_subnet" "euw2-unixkingdom-public" {
  vpc_id            = "${osc_vpc.euw2-unixkingdom-network.id}"
  cidr_block        = "172.16.1.0/24"
  availability_zone = "${var.region}a"

  tags {
    Name = "euw2-unixkingdom-public"
  }
}

resource "osc_subnet" "euw2-unixkingdom-application" {
  vpc_id            = "${osc_vpc.euw2-unixkingdom-network.id}"
  cidr_block        = "172.16.2.0/24"
  availability_zone = "${var.region}a"

  tags {
    Name = "euw2-unixkingdom-application"
  }
}

resource "osc_subnet" "euw2-unixkingdom-storage" {
  vpc_id            = "${osc_vpc.euw2-unixkingdom-network.id}"
  cidr_block        = "172.16.3.0/24"
  availability_zone = "${var.region}a"

  tags {
    Name = "euw2-unixkingdom-storage"
  }
}

resource "osc_subnet" "euw2-unixkingdom-administration" {
  vpc_id            = "${osc_vpc.euw2-unixkingdom-network.id}"
  cidr_block        = "172.16.4.0/24"
  availability_zone = "${var.region}a"

  tags {
    Name = "euw2-unixkingdom-administration"
  }
}

resource "osc_customer_gateway" "euw2-unixkingdom-cgw-paris15" {
  bgp_asn    = 65000
  ip_address = "78.193.70.43"
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

resource "osc_route_table" "euw2-unixkingdom-administration" {
  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  route {
    cidr_block = "${var.lan_subnet}"
    gateway_id = "${osc_vpn_gateway.euw2-unixkingdom-vgw.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${osc_nat_gateway.euw2-unixkingdom.id}"
  }

  tags {
    Name = "euw2-unixkingdom-administration"
  }
}

resource "osc_route_table_association" "euw2-unixkingdom-administration" {
  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"
  route_table_id = "${osc_route_table.euw2-unixkingdom-administration.id}"
}

resource "osc_route_table" "euw2-unixkingdom-public" {
  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  route {
    cidr_block = "${var.lan_subnet}"
    gateway_id = "${osc_vpn_gateway.euw2-unixkingdom-vgw.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${osc_internet_gateway.euw2-unixkingdom-internet.id}"
  }

  tags {
    Name = "euw2-unixkingdom-public"
  }
}

resource "osc_route_table_association" "euw2-unixkingdom-public" {
  subnet_id = "${osc_subnet.euw2-unixkingdom-public.id}"
  route_table_id = "${osc_route_table.euw2-unixkingdom-public.id}"
}

resource "osc_route_table" "euw2-unixkingdom-application" {
  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  route {
    cidr_block = "${var.lan_subnet}"
    gateway_id = "${osc_vpn_gateway.euw2-unixkingdom-vgw.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${osc_nat_gateway.euw2-unixkingdom.id}"
  }

  tags {
    Name = "euw2-unixkingdom-application"
  }
}

resource "osc_route_table_association" "euw2-unixkingdom-application" {
  subnet_id = "${osc_subnet.euw2-unixkingdom-application.id}"
  route_table_id = "${osc_route_table.euw2-unixkingdom-application.id}"
}

resource "osc_route_table" "euw2-unixkingdom-storage" {
  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  route {
    cidr_block = "${var.lan_subnet}"
    gateway_id = "${osc_vpn_gateway.euw2-unixkingdom-vgw.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${osc_nat_gateway.euw2-unixkingdom.id}"
  }

  tags {
    Name = "euw2-unixkingdom-storage"
  }
}

resource "osc_route_table_association" "euw2-unixkingdom-storage" {
  subnet_id = "${osc_subnet.euw2-unixkingdom-storage.id}"
  route_table_id = "${osc_route_table.euw2-unixkingdom-storage.id}"
}

resource "osc_internet_gateway" "euw2-unixkingdom-internet" {
  vpc_id = "${osc_vpc.euw2-unixkingdom-network.id}"

  tags = {
    Name = "euw2-unixkingdom-internet"
  }
}

resource "osc_eip" "euw2-unixkingdom-public-nat" {
  vpc = true
}

resource "osc_eip" "euw2-unixkingdom-public-vpn" {
  network_interface = "${osc_instance.strongswan-1.network_interface_id}"
  vpc = true
}

resource "osc_nat_gateway" "euw2-unixkingdom" {
  allocation_id = "${osc_eip.euw2-unixkingdom-public-nat.id}"
  subnet_id = "${osc_subnet.euw2-unixkingdom-public.id}"
}
