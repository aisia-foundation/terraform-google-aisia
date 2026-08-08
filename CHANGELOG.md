# Changelog — terraform-google-aisia

Format : [Keep a Changelog](https://keepachangelog.com/) · Versioning : SemVer.

## [Unreleased] — correction pré-publication (2026-08-05)

### Fixed
- `image_tag` default et `VERSION` rétablis à `v6.12.80` (dernière version AISIA
  **certifiée LIVE**, DEPLOY-REPORT all-green — `project_facts.json:prod_live_version`).
  Le commit `5a5ab47fa` (bump global « prepare v6.12.81 ») avait fait passer le default
  à `v6.12.81`, alors que cette version est encore 🟡 **PRÉPARÉE** (code seulement — build
  multi-arch, déploiement et DEPLOY-REPORT tous PENDING, cf.
  `artifacts/prepare-v6.12.81.md`). Le commit `8d818d7826e` avait déjà corrigé le texte
  de description (« ex. v6.12.80 ») et les exemples, mais pas la valeur fonctionnelle
  `default`, laissant le module publié avec une incohérence interne (README annonçait
  v6.12.80 partout, le default réel déployait v6.12.81 — tag d'image potentiellement
  inexistant sur `registry.aisia.fr`). Gate `run_terraform_modules_gate` de nouveau vert
  (`VERSION == prod_live_version`). ⚠️ Ce module (`aisia-foundation/aisia/google`) n'est
  **pas encore publié publiquement** (absent de registry.terraform.io au 2026-08-05) —
  contrairement aux 6 autres, aucun rattrapage nécessaire côté registre : la correction
  s'applique dès la première publication.

## [6.12.80] — 2026-08-05

### Changed
- Sync `image_tag` default -> `v6.12.80` (release AISIA v6.12.80 LIVE, DEPLOY-REPORT
  all-green). Entrée rétroactive (bump réel non documenté au moment du commit
  `38058f47f`). Aucun changement fonctionnel des resources/variables/outputs.

## [6.12.79] — 2026-08-04

### Changed
- Sync `image_tag` default -> `v6.12.79` (bump AISIA patch, jamais déployé isolément —
  englobé par la chaîne v6.12.80). Entrée rétroactive (bump réel non documenté au moment
  du commit `0ac97ec9d`). Aucun changement fonctionnel des resources/variables/outputs.

## [6.12.78] — 2026-08-04

### Changed
- Sync `image_tag` default -> `v6.12.78` (release AISIA v6.12.78 LIVE). Rattrape aussi le
  saut `v6.12.77` (VERSION + image_tag bumpés en v6.12.77 par le commit `ad31e4ac8` sans
  entrée CHANGELOG, jamais publié au registry). Aucun changement fonctionnel des
  resources/variables/outputs (patch de synchronisation de version).

## [6.12.76] — 2026-08-02

### Changed
- Sync `image_tag` default -> `v6.12.76` (release AISIA v6.12.76 LIVE). Aucun changement
  fonctionnel des resources/variables/outputs (patch de synchronisation de version).

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
