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
  region     = var.region
}

module "bigquery" {
  source                         = "./modules/fourkeys-bigquery"
  project_id                     = var.project_id
  bigquery_region                = var.bigquery_region
  fourkeys_service_account_email = module.foundation.fourkeys_service_account_email
  depends_on = [
    module.foundation
  ]
}

module "github_parser" {
  source                         = "./modules/fourkeys-data-source"
  for_each                       = toset(var.parsers)
  project_id                     = var.project_id
  parser_service_name            = each.key
  region                         = var.region
  fourkeys_service_account_email = module.foundation.fourkeys_service_account_email
}

module "dashboard_service" {
  source                         = "./modules/fourkeys-dashboard"
  project_id                     = var.project_id
  region                         = var.region
  fourkeys_service_account_email = module.foundation.fourkeys_service_account_email
  depends_on = [
    module.foundation
  ]
}