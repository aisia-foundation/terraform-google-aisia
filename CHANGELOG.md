# Changelog — terraform-google-aisia

Format : [Keep a Changelog](https://keepachangelog.com/) · Versioning : SemVer.

## [1.0.0] — 2026-07-07

### Added
- Module initial publiable (HCP private registry + public `aisia-foundation`) : substrat
  Kubernetes Google **GKE régional**. Parité de famille avec `terraform-aws/azure/ovh/scaleway-aisia`.
- **Réseau** : VPC dédié (`google_compute_network` + `google_compute_subnetwork`) avec ranges
  secondaires `pods` / `services` (ip_allocation_policy VPC-native).
- **Cluster** : `google_container_cluster` régional (`remove_default_node_pool=true`,
  `release_channel` paramétrable, `deletion_protection=false`).
- **Node pools** : pool principal (`e2-standard-4` par défaut, auto_repair/auto_upgrade) + pool GPU
  optionnel (`g2-standard-8` + `nvidia-l4`, autoscale 0→4, taint `nvidia.com/gpu`).
- **Datastores managés conditionnels** : Cloud SQL Postgres 16 (`with_managed_db`) + Memorystore
  Redis 7.2 (`with_managed_cache`), dimensionnés par `profile`.
- **Objets** : bucket GCS d'artefacts (`uniform_bucket_level_access`, `force_destroy`).
- **RGPD** : défaut `region=europe-west1`.
- **Contrat normalisé v6.9.96** : mêmes variables logiques (`org_id`, `service_key`, `runtime_kind`,
  `substrate`, `profile`, `node_count`, `instance_flavor`, `image_registry`, `image_tag`, `domain`,
  `tier`, `gpu_enabled`) + spécifiques GCP (`project_id`, `region`, `gpu_type`, `with_managed_db`,
  `with_managed_cache`). GCP est la référence du contrat (cf. `infra/terraform/gcp`).
- Outputs normalisés : `cluster_id`, `cluster_name`, `cluster_endpoint` (sensitive),
  `cluster_ca_certificate` (sensitive), `kubeconfig_command`, `region`, `node_count`,
  `gpu_pool_enabled`, `artifacts_bucket`, `db_connection_name`, `redis_host`.
- Chaîner avec `terraform-aisia-cluster` pour déployer la stack AISIA sur le substrat GKE.
- Auth GCP : `provider "google"` configuré dans le root module du consumer
  (`GOOGLE_CREDENTIALS` / `GOOGLE_APPLICATION_CREDENTIALS`).
- README (Inputs/Outputs/Usage), LICENSE MPL-2.0, `versions.tf` (TF >= 1.5, google >= 5.0 < 7.0).
- `examples/basic` : usage minimal validable (`terraform validate` / `tofu validate`).
