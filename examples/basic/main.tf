###############################################################################
# Exemple minimal — terraform-google-aisia (substrat GKE)
#
# Prérequis : credentials GCP + projet cible.
#   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/sa-key.json
#   # ou export GOOGLE_CREDENTIALS="$(cat sa-key.json)"
###############################################################################

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
  project = "my-gcp-project"
  region  = "europe-west1"
  # credentials via GOOGLE_CREDENTIALS / GOOGLE_APPLICATION_CREDENTIALS
}

###############################################################################
# L1 — substrat GKE (1 nœud e2-standard-4, profil S)
###############################################################################
module "aisia_google_k8s" {
  # Registre HCP privé (nécessite credentials) :
  #   source  = "app.terraform.io/AISIA/aisia/google"
  #   version = "~> 1.0"
  source = "../../"

  org_id      = "acme"
  service_key = "C1"
  image_tag   = "v6.12.89"
  tier        = "saas"

  project_id   = "my-gcp-project"
  region       = "europe-west1"
  cluster_name = "aisia-acme"
  node_count   = 1
}

###############################################################################
# L2 — déploiement AISIA (dans votre root module après cet example) :
#
# 1. gcloud container clusters get-credentials aisia-acme \
#      --region europe-west1 --project my-gcp-project
# 2. provider "kubernetes" { config_path = "~/.kube/config" }
# 3. module "aisia_app" { source = "app.terraform.io/AISIA/aisia-cluster/kubernetes" ... }
###############################################################################

output "kubeconfig_command" {
  value = module.aisia_google_k8s.kubeconfig_command
}
