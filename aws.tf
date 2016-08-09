variable "availability_zone" {default = "us-east-1a"}
variable "count_format" {default = "%02d"}
variable "short_name" {default = "gstv"}
variable "long_name" {default = "gas-stack"}
variable "network_ipv4" {default = "10.0.0.0/16"}
variable "network_subnet_ip4" {default = "10.0.0.0/16"}
variable "source_ami" {default = "ami-2d39803a"}
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_username"  {default = "ubuntu"}

variable "docker_count" {default = "2"}
variable "docker_iam_profile" {default = "" }
variable "docker_type" {default = "t2.medium"}
variable "docker_volume_size" {default = "20"} # size is in gigabytes
variable "docker_data_volume_size" {default = "100"} # size is in gigabytes

variable "haproxy_count" {default = "1"}
variable "haproxy_iam_profile" {default = "" }
variable "haproxy_type" {default = "m3.medium"}
variable "haproxy_volume_size" {default = "20"} # size is in gigabytes
variable "haproxy_data_volume_size" {default = "20"} # size is in gigabytes

resource "aws_vpc" "main" {
  cidr_block = "${var.network_ipv4}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.long_name}"
  }
}

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.network_subnet_ip4}"
  availability_zone = "${var.availability_zone}"
  tags {
    Name = "${var.long_name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.long_name}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.long_name}"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_ebs_volume" "gst-haproxy-lvm" {
  availability_zone = "${var.availability_zone}"
  count = "${var.haproxy_count}"
  size = "${var.haproxy_data_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.short_name}-haproxy-lvm-${format("%02d", count.index+1)}"
  }
}

resource "aws_instance" "gst-haproxy-nodes" {
  ami = "${var.source_ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.haproxy_type}"
  count = "${var.haproxy_count}"
  vpc_security_group_ids = ["${aws_security_group.haproxy.id}",
    "${aws_security_group.ui.id}",
    "${aws_vpc.main.default_security_group_id}"]

  key_name = "${aws_key_pair.deployer.key_name}"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.main.id}"
  iam_instance_profile = "${var.haproxy_iam_profile}"

  root_block_device {
    delete_on_termination = true
    volume_size = "${var.haproxy_volume_size}"
  }

  tags {
    Name = "${var.short_name}-haproxy-${format("%02d", count.index+1)}"
    sshUser = "${var.ssh_username}"
    role = "haproxy"
  }
}

resource "aws_volume_attachment" "gst-haproxy-nodes-lvm-attachment" {
  count = "${var.haproxy_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.gst-haproxy-nodes.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.gst-haproxy-lvm.*.id, count.index)}"
  force_detach = true
}

resource "aws_ebs_volume" "gst-docker-lvm" {
  availability_zone = "${var.availability_zone}"
  count = "${var.docker_count}"
  size = "${var.docker_data_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.short_name}-docker-lvm-${format("%02d", count.index+1)}"
  }
}

resource "aws_instance" "gst-docker-nodes" {
  ami = "${var.source_ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.docker_type}"
  count = "${var.docker_count}"

  vpc_security_group_ids = ["${aws_security_group.docker.id}",
    "${aws_vpc.main.default_security_group_id}"]


  key_name = "${aws_key_pair.deployer.key_name}"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.main.id}"
  iam_instance_profile = "${var.docker_iam_profile}"

  root_block_device {
    delete_on_termination = true
    volume_size = "${var.docker_volume_size}"
  }

  tags {
    Name = "${var.short_name}-docker-${format(var.count_format, count.index+1)}"
    sshUser = "${var.ssh_username}"
    role = "docker"
  }
}

resource "aws_volume_attachment" "gst-docker-nodes-lvm-attachment" {
  count = "${var.docker_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.gst-docker-nodes.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.gst-docker-lvm.*.id, count.index)}"
  force_detach = true
}

resource "aws_security_group" "haproxy" {
  name = "${var.short_name}-haproxy"
  description = "Allow inbound traffic for haproxy nodes"
  vpc_id = "${aws_vpc.main.id}"

  ingress { # SSH
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Mesos
    from_port = 5050
    to_port = 5050
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Marathon
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Chronos
    from_port = 4400
    to_port = 4400
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Consul
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # ICMP
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "docker" {
  name = "${var.short_name}-docker"
  description = "Allow inbound traffic for docker nodes"
  vpc_id = "${aws_vpc.main.id}"

  ingress { # SSH
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # HTTP
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # HTTPS
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Mesos
    from_port = 5050
    to_port = 5050
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Marathon
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Consul
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # ICMP
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ui" {
  name = "${var.short_name}-ui"
  description = "Allow inbound traffic for http"
  vpc_id = "${aws_vpc.main.id}"

  ingress { # HTTP
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # HTTPS
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Consul
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name = "key-${var.short_name}"
  public_key = "${file(var.ssh_key)}"
}

output "vpc_subnet" {
  value = "${aws_subnet.main.id}"
}

output "haproxy_security_group" {
  value = "${aws_security_group.haproxy.id}"
}

output "docker_security_group" {
  value = "${aws_security_group.docker.id}"
}

output "ui_security_group" {
  value = "${aws_security_group.ui.id}"
}

output "default_security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

output "haproxy_ids" {
  value = "${join(\",\", aws_instance.gst-haproxy-nodes.*.id)}"
}

output "haproxy_ips" {
  value = "${join(\",\", aws_instance.gst-haproxy-nodes.*.public_ip)}"
}

output "docker_ips" {
  value = "${join(\",\", aws_instance.gst-docker-nodes.*.public_ip)}"
}
