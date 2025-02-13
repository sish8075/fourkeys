resource "google_project_service" "bigquery" {
  project            = var.project_id
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

# BigQuery dataset and tables
resource "google_bigquery_dataset" "four_keys" {
  project    = var.project_id
  dataset_id = "four_keys"
  location   = var.bigquery_region
  depends_on = [
    google_project_service.bigquery
  ]
}

resource "google_bigquery_table" "events_raw" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.four_keys.dataset_id
  table_id            = "events_raw"
  schema              = file("${path.module}/files/events_raw_schema.json")
  deletion_protection = true
  depends_on = [
    google_project_service.bigquery
  ]
}

resource "google_bigquery_table" "view_changes" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.four_keys.dataset_id
  table_id   = "changes"
  view {
    query          = file("${path.module}/queries/changes.sql")
    use_legacy_sql = false
  }
  deletion_protection = false
  depends_on = [
    google_project_service.bigquery,
    google_bigquery_table.events_raw
  ]
}

resource "google_bigquery_routine" "func_json2array" {
  project      = var.project_id
  dataset_id   = google_bigquery_dataset.four_keys.dataset_id
  routine_id   = "json2array"
  routine_type = "SCALAR_FUNCTION"
  return_type  = "{\"typeKind\": \"ARRAY\", \"arrayElementType\": {\"typeKind\": \"STRING\"}}"
  language     = "JAVASCRIPT"
  arguments {
    name      = "json"
    data_type = "{\"typeKind\" :  \"STRING\"}"
  }
  definition_body = file("${path.module}/queries/function_json2array.js")
  depends_on = [
    google_project_service.bigquery
  ]
}

resource "google_bigquery_table" "view_deployments" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.four_keys.dataset_id
  table_id   = "deployments"
  view {
    query          = file("${path.module}/queries/deployments.sql")
    use_legacy_sql = false
  }
  deletion_protection = false
  depends_on = [
    google_project_service.bigquery,
    google_bigquery_table.events_raw,
    google_bigquery_routine.func_json2array
  ]
}

resource "google_bigquery_table" "view_incidents" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.four_keys.dataset_id
  table_id   = "incidents"
  view {
    query          = file("${path.module}/queries/incidents.sql")
    use_legacy_sql = false
  }
  deletion_protection = false
  depends_on = [
    google_project_service.bigquery,
    google_bigquery_table.events_raw,
    google_bigquery_table.view_deployments
  ]
}

# BigQuery IAM
resource "google_bigquery_dataset_iam_member" "parser_bq" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.four_keys.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${var.fourkeys_service_account_email}"
}