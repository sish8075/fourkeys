terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      version = "~> 3.85.0"
    }
  }
}

module "foundation" {
  source     = "./modules/fourkeys-foundation"
  project_id = var.project_id
}