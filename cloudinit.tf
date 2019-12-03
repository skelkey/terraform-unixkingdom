data "template_file" "minion" {
  template = "${file("${path.module}/minion.tpl")}"

  vars = {
    saltmaster = "${osc_instance.euw2a-prd-unixkingdom-saltstack-1.private_ip}"
  }
}
