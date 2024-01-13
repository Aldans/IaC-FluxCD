module "bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 5.0"

  name       = var.GKE_BUCKET_NAME
  project_id = var.GOOGLE_PROJECT
  location   = var.GOOGLE_REGION 
  force_destroy = true
}

