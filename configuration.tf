variable profile {}
variable region {}
variable url_ec2 {}
variable url_iam {}
variable ami {}
variable user {}
variable sshkey {}
variable private_key {}
variable lan_subnet {}

provider "osc" {
  profile                     = "${var.profile}"
  region                      = "${var.region}"
  skip_region_validation      = true

  endpoints {
    ec2 = "${var.url_ec2}"
    iam = "${var.url_iam}"
  }
}
