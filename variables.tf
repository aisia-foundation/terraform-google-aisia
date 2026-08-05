###############################################################################
# terraform-google-aisia — variables d'entrée.
# Substrat Kubernetes Google GKE (régional). Contrat normalisé v6.9.96.
#
# Auth GCP : le consumer configure `provider "google" { ... }` dans son root
# module (project + region) avec GOOGLE_CREDENTIALS / GOOGLE_APPLICATION_CREDENTIALS.
# Ces credentials ne transitent pas par les variables du module.
###############################################################################

# ── Contrat normalisé (commun à tous les clouds × substrats) ───────────────
variable "org_id" {
  description = "Identifiant de l'organisation AISIA (tenant)."
  type        = string
}

variable "service_key" {
  description = "Brique déployée (C1..C11)."
  type        = string
}

variable "runtime_kind" {
  description = "edge | compute | compute-gpu | data | ops | security."
  type        = string
  default     = "compute"
}

variable "substrate" {
  description = "Substrat cible. Ce module provisionne le substrat 'k8s' (GKE)."
  type        = string
  default     = "k8s"
}

variable "profile" {
  description = "Profil de dimensionnement (S | M | L | XL)."
  type        = string
  default     = "S"
}

variable "node_count" {
  description = "Nombre de nœuds du pool principal GKE."
  type        = number
  default     = 1
}

variable "instance_flavor" {
  description = "Machine type GCE des nœuds du pool principal (ex : e2-standard-4)."
  type        = string
  default     = "e2-standard-4"
}

variable "image_registry" {
  description = "Registry des images AISIA (app déployée via terraform-aisia-cluster)."
  type        = string
  default     = "registry.aisia.fr"
}

variable "image_tag" {
  description = "Tag d'image AISIA à déployer (ex. v6.12.81)."
  type        = string
  default     = "v6.12.81"
}

variable "domain" {
  description = "Domaine custom de l'org (vide = *.aisia.fr)."
  type        = string
  default     = ""
}

variable "tier" {
  description = "Offre tarifaire AISIA (saas | baas | paas)."
  type        = string
  default     = "saas"
  validation {
    condition     = contains(["saas", "baas", "paas"], var.tier)
    error_message = "tier doit etre 'saas', 'baas' ou 'paas'."
  }
}

variable "gpu_enabled" {
  description = "Provisionner un pool GPU GKE (runtime compute-gpu / inférence C4)."
  type        = bool
  default     = false
}

# ── Spécifiques Google GKE ────────────────────────────────────────────────
variable "project_id" {
  description = "ID du projet GCP cible (requis)."
  type        = string
}

variable "region" {
  description = "Région GCP GKE régional (europe-west1 par défaut pour conformité RGPD)."
  type        = string
  default     = "europe-west1"
}

variable "cluster_name" {
  description = "Préfixe logique du cluster GKE (sinon dérivé de org_id/service_key)."
  type        = string
  default     = ""
}

variable "release_channel" {
  description = "Canal de release GKE (RAPID | REGULAR | STABLE)."
  type        = string
  default     = "REGULAR"
}

variable "gpu_type" {
  description = "Type d'accélérateur GPU (doc GCP : nvidia-tesla-t4 | nvidia-l4 | nvidia-tesla-a100)."
  type        = string
  default     = "nvidia-l4"
}

variable "gpu_node_flavor" {
  description = "Machine type des nœuds du pool GPU optionnel (g2-standard-8 = 1× L4)."
  type        = string
  default     = "g2-standard-8"
}

variable "with_managed_db" {
  description = "Provisionner Cloud SQL Postgres (briques data)."
  type        = bool
  default     = false
}

variable "with_managed_cache" {
  description = "Provisionner Memorystore Redis (briques data/ops)."
  type        = bool
  default     = false
}
