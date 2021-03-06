variable profile {}
variable region {}
variable url_ec2 {}
variable url_iam {}
variable url_elb {}
variable ami {}
variable sshkey {}
variable lan_subnet {}
variable allowed_external_cidr {}
variable zabbix_proxy_cidr {
  type = "list"
  default = []
}

provider "osc" {
  profile                     = "${var.profile}"
  region                      = "${var.region}"
  skip_region_validation      = true

  endpoints {
    ec2 = "${var.url_ec2}"
    iam = "${var.url_iam}"
    elb = "${var.url_elb}"
  }
}
