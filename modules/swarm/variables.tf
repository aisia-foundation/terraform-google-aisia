# Contrat de variables NORMALISÉ v6.14.1 (identique k8s ↔ swarm, tous clouds).
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
  default = "v6.14.2"
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

variable "ssh_allowed_cidrs" {
  description = "CIDRs optionnels autorisés à se connecter en SSH. Une liste vide désactive l'exposition SSH."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for cidr in var.ssh_allowed_cidrs :
      cidr != "0.0.0.0/0" && can(cidrhost(cidr, 0))
    ])
    error_message = "ssh_allowed_cidrs ne peut contenir 0.0.0.0/0 et chaque valeur doit être un CIDR valide. Une liste vide désactive SSH."
  }
}
