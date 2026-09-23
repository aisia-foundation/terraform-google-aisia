# GCE + Docker Swarm. 1 manager + var.node_count workers.
# v6.14.1 — provisionne le substrat Swarm (co-primaire avec K8s).
#
# Note bootstrap : le startup-script installe Docker et init le Swarm sur le
# manager. Le JOIN des workers nécessite le token du manager (récupéré post-apply
# par le worker T7 via SSH/metadata) — documenté, pas de faux succès dans le TF.

locals {
  zone = var.zone != "" ? var.zone : "${var.region}-b"
  name = "aisia-${var.org_id}-${var.service_key}"
  labels = {
    aisia_org     = var.org_id
    aisia_service = var.service_key
    managed_by    = "aisia-terraform"
  }
  docker_install = <<-EOT
    #!/bin/bash
    set -e
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
  EOT
}

resource "google_compute_network" "vpc" {
  name                    = "${local.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${local.name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.30.0.0/20"
}

# Firewall public limité aux entrées web.
resource "google_compute_firewall" "public_web" {
  name    = "${local.name}-public-web-fw"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# Plan de contrôle Swarm limité au subnet privé des nœuds.
resource "google_compute_firewall" "swarm_internal" {
  name    = "${local.name}-internal-fw"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["2377", "7946"]
  }
  allow {
    protocol = "udp"
    ports    = ["7946", "4789"]
  }
  source_ranges = ["10.30.0.0/20"]
}

resource "google_compute_firewall" "ssh" {
  count   = length(var.ssh_allowed_cidrs) > 0 ? 1 : 0
  name    = "${local.name}-ssh-fw"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.ssh_allowed_cidrs
}

resource "google_compute_instance" "manager" {
  name         = "${local.name}-mgr"
  machine_type = var.instance_flavor
  zone         = local.zone
  labels       = local.labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 50
    }
  }
  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }
  metadata = {
    ssh-keys       = var.ssh_public_key != "" ? "${var.ssh_user}:${var.ssh_public_key}" : null
    startup-script = "${local.docker_install}\ndocker swarm init || true\n"
  }
}

resource "google_compute_instance" "worker" {
  count        = var.node_count
  name         = "${local.name}-w${count.index}"
  machine_type = var.instance_flavor
  zone         = local.zone
  labels       = merge(local.labels, { aisia_role = "worker" })

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 50
    }
  }
  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }
  metadata = {
    ssh-keys       = var.ssh_public_key != "" ? "${var.ssh_user}:${var.ssh_public_key}" : null
    startup-script = local.docker_install
  }
}
