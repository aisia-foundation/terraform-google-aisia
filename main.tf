###############################################################################
# terraform-google-aisia — substrat Kubernetes Google GKE (régional).
#
#   ┌──────────────────────────────────────────────────────────────────────┐
#   │ google_compute_network / subnetwork (VPC dédié, ranges pods/services)│
#   │ google_container_cluster (GKE régional, remove_default_node_pool)     │
#   │ google_container_node_pool (pool principal, auto_repair/upgrade)      │
#   │ google_container_node_pool (pool GPU optionnel, autoscale 0→4)        │
#   │ google_storage_bucket (artefacts / backups objets)                    │
#   │ google_sql_database_instance (Cloud SQL Postgres, conditionnel)       │
#   │ google_redis_instance (Memorystore Redis, conditionnel)               │
#   └──────────────────────────────────────────────────────────────────────┘
#
# Usage : chaîner avec terraform-aisia-cluster pour déployer la stack AISIA.
# Le consumer configure `provider "google" { project, region }` dans son root
# module. L'output `kubeconfig_command` alimente le kubeconfig local, puis les
# providers kubernetes/helm du root module appellent terraform-aisia-cluster.
###############################################################################

locals {
  name = var.cluster_name != "" ? var.cluster_name : "aisia-${var.org_id}-${var.service_key}"

  labels = {
    aisia_org     = var.org_id
    aisia_service = var.service_key
    aisia_tier    = var.tier
    managed_by    = "aisia-terraform"
  }
}

###############################################################################
# Réseau dédié
###############################################################################
resource "google_compute_network" "vpc" {
  name                    = "${local.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${local.name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.20.0.0/20"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.21.0.0/16"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.22.0.0/20"
  }
}

###############################################################################
# Cluster GKE régional (control plane managé)
###############################################################################
resource "google_container_cluster" "gke" {
  name       = local.name
  location   = var.region
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  release_channel {
    channel = var.release_channel
  }
  resource_labels = local.labels
}

###############################################################################
# Pool de nœuds principal
###############################################################################
resource "google_container_node_pool" "primary" {
  name       = "${local.name}-primary"
  location   = var.region
  cluster    = google_container_cluster.gke.name
  node_count = var.node_count

  node_config {
    machine_type = var.instance_flavor
    disk_size_gb = 50
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels       = local.labels
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

###############################################################################
# Pool GPU optionnel (inférence C4)
###############################################################################
resource "google_container_node_pool" "gpu" {
  count      = var.gpu_enabled ? 1 : 0
  name       = "${local.name}-gpu"
  location   = var.region
  cluster    = google_container_cluster.gke.name
  node_count = 1

  node_config {
    machine_type = var.gpu_node_flavor
    disk_size_gb = 100
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    guest_accelerator {
      type  = var.gpu_type
      count = 1
    }
    labels = merge(local.labels, { aisia_pool = "gpu" })
    taint {
      key    = "nvidia.com/gpu"
      value  = "present"
      effect = "NO_SCHEDULE"
    }
  }
  autoscaling {
    min_node_count = 0
    max_node_count = 4
  }
}

###############################################################################
# Bucket GCS (artefacts / backups objets)
###############################################################################
resource "google_storage_bucket" "artifacts" {
  name                        = "${local.name}-artifacts"
  location                    = upper(split("-", var.region)[0])
  uniform_bucket_level_access = true
  force_destroy               = true
  labels                      = local.labels
}

###############################################################################
# Cloud SQL Postgres (conditionnel : briques data)
###############################################################################
resource "google_sql_database_instance" "pg" {
  count            = var.with_managed_db ? 1 : 0
  name             = "${local.name}-pg"
  region           = var.region
  database_version = "POSTGRES_16"

  settings {
    tier              = var.profile == "S" ? "db-f1-micro" : "db-custom-2-7680"
    availability_type = contains(["L", "XL"], var.profile) ? "REGIONAL" : "ZONAL"
    backup_configuration {
      enabled = true
    }
    user_labels = local.labels
  }
  deletion_protection = false
}

###############################################################################
# Memorystore Redis (conditionnel : briques data/ops)
###############################################################################
resource "google_redis_instance" "cache" {
  count          = var.with_managed_cache ? 1 : 0
  name           = "${local.name}-redis"
  region         = var.region
  tier           = contains(["L", "XL"], var.profile) ? "STANDARD_HA" : "BASIC"
  memory_size_gb = 1
  redis_version  = "REDIS_7_2"
  labels         = local.labels
}
