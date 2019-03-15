resource "osc_instance" "euw2a-prd-unixkingdom-openvpn-1" {
  ami               = "${var.ami}"
  availability_zone = "${var.region}a"
  instance_type     = "c4.large"
  key_name          = "${var.sshkey}"

  vpc_security_group_ids = [
    "${osc_security_group.euw2-prd-unixkingdom-openvpn.id}",
  ]

  subnet_id = "${osc_subnet.euw2-unixkingdom-administration.id}"

  tags {
    Name = "euw2-prd-unixkingdom-openvpn-1"
  }
}

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
    Name = "euw2-prd-unixkingdom-saltstack-1"
  }
}

output "euw2a-prd-unixkingdom-openvpn-1" {
  value = "${osc_instance.euw2a-prd-unixkingdom-openvpn-1.private_ip}"
}

output "euw2a-prd-unixkingdom-saltstack-1" {
  value = "${osc_instance.euw2a-prd-unixkingdom-saltstack-1.private_ip}"
}
