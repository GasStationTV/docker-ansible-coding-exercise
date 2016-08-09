variable "docker_count" { default = 2 }
variable "docker_type" { default = "n1-standard-1" }
variable "haproxy_count" { default = 1}
variable "haproxy_type" { default = "g1-small" }
variable "image" {default = "centos-7-v20160803"}
variable "long_name" {default = "gastv"}
variable "short_name" {default = "gtv"}
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_user" {default = "centos"}
variable "zones" {
  default = "us-east1-b"
}

provider "google" {
  credentials = "${file("account.json")}"
  project = "gas-stack"
  region = "us-east1"
}

module "gce-network" {
  source = "./terraform/gce/network"
  network_ipv4 = "10.0.0.0/16"
  long_name = "${var.long_name}"
  short_name = "${var.short_name}"
}

module "docker-nodes" {
  source = "./terraform/gce/instance"
  count = "${var.docker_count}"
  /*datacenter = "${var.datacenter}"*/
  image = "${var.image}"
  machine_type = "${var.docker_type}"
  network_name = "${module.gce-network.network_name}"
  role = "docker"
  short_name = "${var.short_name}"
  ssh_user = "${var.ssh_user}"
  ssh_key = "${var.ssh_key}"
  zones = "${var.zones}"
}

module "haproxy-nodes" {
  source = "./terraform/gce/instance"
  count = "${var.haproxy_count}"
  /*datacenter = "${var.datacenter}"*/
  image = "${var.image}"
  machine_type = "${var.haproxy_type}"
  network_name = "${module.gce-network.network_name}"
  role = "haproxy"
  short_name = "${var.short_name}"
  ssh_user = "${var.ssh_user}"
  ssh_key = "${var.ssh_key}"
  zones = "${var.zones}"
}

/*module "network-lb" {
  source = "./terraform/gce/lb"
  instances = "${module.haproxy-nodes.instances}"
  short_name = "${var.short_name}"
}*/
