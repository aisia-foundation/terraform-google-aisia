# GCP — substrat Swarm (GCE + Docker Swarm). v6.13.16 (dual-substrate, co-primaire).
terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
