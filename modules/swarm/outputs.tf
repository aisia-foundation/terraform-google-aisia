output "manager_ip" {
  description = "IP publique du manager Swarm."
  value       = google_compute_instance.manager.network_interface[0].access_config[0].nat_ip
}

output "worker_ips" {
  description = "IPs publiques des workers Swarm."
  value       = [for w in google_compute_instance.worker : w.network_interface[0].access_config[0].nat_ip]
}

output "region" {
  description = "Région GCP du déploiement."
  value       = var.region
}

output "node_count" {
  description = "Nombre de workers provisionnés (hors manager)."
  value       = var.node_count
}

output "join_note" {
  description = "Rappel : le join des workers utilise le token du manager (post-apply, worker T7)."
  value       = "docker swarm join-token worker -q  # sur le manager, puis join sur chaque worker"
}
