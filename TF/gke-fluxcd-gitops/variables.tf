variable "algorithm" {
  type    = string
  default = "RSA"
}
  
# variable "project_id" {
#   description = "project id"
#   type        = string
# }

variable "github_token" {
  description = "token for github"
  type        = string
}

variable "github_owner" {
  description = "github owner"
  type        = string
}

variable "repository_name" {
  description = "repository name"
  type        = string
  default = "flux-gitops-gke"
}

variable "branch" {
  description = "branch"
  type        = string
  default     = "main"
}

variable "target_path" {
  type        = string
  description = "Relative path to the Git repository root where the sync manifests are committed."
  default = "clusters"
}

variable "flux_namespace" {
  type        = string
  default     = "flux-system"
  description = "the flux namespace"
}

variable "cluster_name" {
  type        = string
  description = "cluster name"
  default = "gitops-gke"
}

variable "cluster_region" {
  type        = string
  description = "cluster region"
  default = "us-central1-c"
}

variable "use_private_endpoint" {
  type        = bool
  description = "Connect on the private GKE cluster endpoint"
  default     = false
}

variable "github_deploy_key_title" {
  type        = string
  description = "Name of github deploy key"
  default = "flux"
}

variable "GOOGLE_PROJECT" {
  type        = string
  description = "GCP project name"
}

variable "GOOGLE_REGION" {
  type        = string
  default     = "us-central1-c"
  description = "GCP region to use"
}

variable "config_host" {
  type        = string
  default     = "gke"
  description = "The url for gke"
}

variable "config_token" {
  type        = string
  default     = "token"
  description = "The token for gke"
}

variable "config_ca" {
  type        = string
  default     = "ca"
  description = "The ca for gke"
}

variable "GKE_CLUSTER_NAME" {
  type        = string
  default     = "gitops-gke"
}

variable "GKE_POOL_NAME" {
  type        = string
  default     = "gitops-gke-pool"
}

variable "GKE_NUM_NODES" {
  type        = string
  default     = 2
}

variable "GKE_MACHINE_TYPE" {
  type        = string
  # default     = "g1-small"
  default     = "e2-medium"
}

variable "GKE_BUCKET_NAME" {
  type        = string
  description = "The bucket name"
  default = "ops-config-bucket"
}
