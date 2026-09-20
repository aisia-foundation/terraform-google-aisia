# Contrat de variables NORMALISÉ v6.13.16 (identique k8s ↔ swarm, tous clouds).
variable "org_id" {
  type = string
}

variable "service_key" {
  type = string
}

variable "runtime_kind" {
  type    = string
  default = "compute"
}

variable "substrate" {
  type    = string
  default = "swarm"
}

variable "profile" {
  type    = string
  default = "S"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "node_count" {
  description = "Nombre de workers Swarm (le manager est en plus)."
  type        = number
  default     = 1
}

variable "instance_flavor" {
  type    = string
  default = "e2-standard-4"
}

variable "image_registry" {
  type    = string
  default = "registry.aisia.fr"
}

variable "image_tag" {
  type    = string
  default = "v6.13.16"
}

variable "domain" {
  type    = string
  default = ""
}

variable "tier" {
  type    = string
  default = "saas"
}

variable "gpu_enabled" {
  type    = bool
  default = false
}

# — Spécifiques GCP —
variable "project_id" {
  type = string
}

variable "zone" {
  description = "Zone GCE (déduite de la région si vide)."
  type        = string
  default     = ""
}

variable "ssh_user" {
  type    = string
  default = "aisia"
}

variable "ssh_public_key" {
  description = "Clé publique SSH pour l'accès aux instances (vide = pas d'accès SSH)."
  type        = string
  default     = ""
}
