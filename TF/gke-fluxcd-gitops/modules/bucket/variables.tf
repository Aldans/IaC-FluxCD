variable "GKE_BUCKET_NAME" {
  type        = string
  description = "GKE bucket name"
}

variable "GOOGLE_PROJECT" {
  type        = string
  description = "GCP project name"
}

variable "GOOGLE_REGION" {
  type        = string
  description = "GCP bucket region"
  default = "us-central1"
}
