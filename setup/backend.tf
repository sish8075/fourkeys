terraform {
  backend "gcs" {
    bucket = "shadamn-4keys-terraform-state"
    prefix = "terraform/state"
  }
}
