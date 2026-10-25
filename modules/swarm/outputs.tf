output "manager_ip" {
  description = "IP publique du manager Swarm (IP privée si manager_public_ip = false)."
  value = (
    var.manager_public_ip
    ? google_compute_instance.manager.network_interface[0].access_config[0].nat_ip
    : google_compute_instance.manager.network_interface[0].network_ip
  )
}

output "manager_private_ip" {
  description = "IP privée du manager (advertise-addr Swarm, rebond SSH vers les workers privés)."
  value       = google_compute_instance.manager.network_interface[0].network_ip
}

output "worker_ips" {
  description = "IPs des workers Swarm : publiques si worker_public_ip = true, privées sinon (défaut)."
  value = [
    for w in google_compute_instance.worker :
    var.worker_public_ip ? w.network_interface[0].access_config[0].nat_ip : w.network_interface[0].network_ip
  ]
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
