module "kind_cluster" {
  source = "github.com/aldans/tf-kind-cluster?ref=cert_auth"
}

module "tls_private_key" {
  source    = "github.com/aldans/tf-hashicorp-tls-keys"
  algorithm = var.algorithm
}

module "github-repository" {
  source                   = "github.com/aldans/tf-github-repository"
  github_owner             = var.github_owner
  github_token             = var.github_token
  repository_name          = var.repository_name
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux"
}

module "fluxcd" {
  source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap?ref=kind_auth"
  github_repository = "${var.github_owner}/${var.repository_name}"
  private_key       = module.tls_private_key.private_key_pem
  config_host       = module.kind_cluster.endpoint
  config_client_key = module.kind_cluster.client_key
  config_ca         = module.kind_cluster.ca
  config_crt        = module.kind_cluster.crt
  github_token      = var.github_token
}
