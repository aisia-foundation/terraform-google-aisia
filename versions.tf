###############################################################################
# terraform-google-aisia — contraintes providers (module publiable, sans bloc provider).
# Le consumer configure `provider "google" { ... }` dans son root module.
###############################################################################
terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
