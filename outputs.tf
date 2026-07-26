###############################################################################
# terraform-google-aisia — outputs (contrat normalisé substrat GKE).
# Utiliser kubeconfig_command pour peupler le kubeconfig local, puis configurer
# les providers kubernetes/helm du root module et appeler terraform-aisia-cluster.
###############################################################################

output "cluster_id" {
  description = "ID du cluster GKE."
  value       = google_container_cluster.gke.id
}

output "cluster_name" {
  description = "Nom du cluster GKE."
  value       = google_container_cluster.gke.name
}

output "cluster_endpoint" {
  description = "Endpoint du control plane GKE (sensible)."
  value       = google_container_cluster.gke.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate du control plane GKE (base64, sensible)."
  value       = google_container_cluster.gke.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Commande gcloud pour récupérer le kubeconfig du cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --region ${var.region} --project ${var.project_id}"
}

output "region" {
  description = "Région GCP du déploiement."
  value       = var.region
}

output "node_count" {
  description = "Taille du pool de nœuds principal."
  value       = google_container_node_pool.primary.node_count
}

output "gpu_pool_enabled" {
  description = "Un pool GPU a-t-il été provisionné ?"
  value       = var.gpu_enabled
}

output "artifacts_bucket" {
  description = "Bucket GCS d'artefacts."
  value       = google_storage_bucket.artifacts.name
}

output "db_connection_name" {
  description = "Connection name Cloud SQL (vide si non provisionné)."
  value       = var.with_managed_db ? google_sql_database_instance.pg[0].connection_name : ""
}

output "redis_host" {
  description = "Host Memorystore Redis (vide si non provisionné)."
  value       = var.with_managed_cache ? google_redis_instance.cache[0].host : ""
}
