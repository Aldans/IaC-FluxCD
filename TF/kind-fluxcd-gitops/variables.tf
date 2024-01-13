# hashicorp-tls-keys
variable "algorithm" {
  type    = string
  default = "RSA"
}

# github-repository
variable "github_owner" {
  type = string
}

variable "github_token" {
  type = string
}

variable "repository_name" {
  type    = string
  default = "flux-gitops"
}

# fcluxcd
