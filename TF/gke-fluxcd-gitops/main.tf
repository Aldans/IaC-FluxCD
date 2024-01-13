# GIT ----------------------------------------------------------------------------------

module "github_repository" {
  source                   = "github.com/aldans/tf-github-repository"
  github_owner             = var.github_owner
  github_token             = var.github_token
  repository_name          = var.repository_name
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux"
}

module "tls_private_key" {
  source = "github.com/aldans/tf-hashicorp-tls-keys"
}

# GKE ----------------------------------------------------------------------------------

 module "gke_cluster" {
  source         = "github.com/aldans/tf-google-gke-cluster?ref=gke_auth"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = 2
  GKE_MACHINE_SPOT = true
  GKE_MACHINE_DISK_SIZE = 50
  GKE_MACHINE_DISK_TYPE = "pd-standard"
}

# FLUXCD ----------------------------------------------------------------------------------

module "flux_bootstrap" {
  source            = "github.com/aldans/tf-fluxcd-flux-bootstrap?ref=gke_auth"
  github_repository = "${var.github_owner}/${var.repository_name}"
  private_key       = module.tls_private_key.private_key_pem
  # config_path       = module.gke_cluster.kubeconfig
  config_host       = module.gke_cluster.config_host
  config_token      = module.gke_cluster.config_token
  config_ca         = module.gke_cluster.config_ca
  github_token      = var.github_token
} 

# BUCKET ----------------------------------------------------------------------------------

module "bucket" {
  source = "./modules/bucket"
  GOOGLE_PROJECT  = var.GOOGLE_PROJECT
  GKE_BUCKET_NAME = "config-ops-gke"
}

# !Uncoment after bucket created

# terraform {
#   backend "gcs" {
#     bucket = "config-ops-gke"
#     prefix = "terraform/state"
#   }
# }

