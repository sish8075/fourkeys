variable "project_id" {
    type    = string
    description = "project to deploy four keys resources to"
}

variable "region" {
    type = string
    description = "Region to deploy fource keys resources in."
}

variable "bigquery_region" {
  type = string
  description = "Region to deploy BigQuery resources in."
  validation {
    condition = can(regex("^(US|EU)$", var.bigquery_region))
    error_message = "The value for 'bigquery_region' must be one of: 'US','EU'."
  }
}

variable "parsers" {
  type = list(string)
  description =  "List of data parsers to configure. Acceptable values are: 'github', 'gitlab', 'cloud-build', 'tekton'"
}

variable "backend_bucket" {
  type = string
  description =  "GCP bucket for Terrafrom backend"
}