variable "long_name" {default = "gastv"}
variable "network_ipv4" {default = "10.0.0.0/16"}
variable "short_name" {default = "gastv"}

# Network
resource "google_compute_network" "gastv-network" {
  name = "${var.long_name}"
  ipv4_range = "${var.network_ipv4}"
}

# Firewall
resource "google_compute_firewall" "gastv-firewall-external" {
  name = "${var.short_name}-firewall-external"
  network = "${google_compute_network.gastv-network.name}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["1-65535"]
  }
}

resource "google_compute_firewall" "-firewall-internal" {
  name = "${var.short_name}-firewall-internal"
  network = "${google_compute_network.gastv-network.name}"
  source_ranges = ["${google_compute_network.gastv-network.ipv4_range}"]

  allow {
    protocol = "tcp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "4"
  }
}


output "network_name" {
  value = "${google_compute_network.gastv-network.name}"
}

output "ip_range" {
  value = "${google_compute_network.gastv-network.ipv4_range}"
}
