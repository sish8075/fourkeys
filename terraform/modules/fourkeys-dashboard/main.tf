module "gcloud_build_dashboard" {
  source                 = "terraform-google-modules/gcloud/google"
  version                = "~> 3.0"
  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "builds submit ${path.module}/files/dashboard --tag=gcr.io/${var.project_id}/fourkeys-grafana-dashboard --project=${var.project_id}"
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "container images delete gcr.io/${var.project_id}/fourkeys-grafana-dashboard --quiet"
}

resource "google_cloud_run_service" "dashboard" {
  project  = var.project_id
  location = var.region
  name     = "fourkeys-grafana-dashboard"

  template {
    spec {
      containers {
        ports {
          container_port = 3000
        }
        image = "gcr.io/${var.project_id}/fourkeys-grafana-dashboard"
        env {
          name  = "PROJECT_NAME"
          value = var.project_id
        }
      }
      service_account_name = var.fourkeys_service_account_email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  
  autogenerate_revision_name = true
  depends_on = [
    module.gcloud_build_dashboard
  ]

  metadata {
    labels = {"created_by":"fourkeys"}
  }
}

resource "google_cloud_run_service_iam_binding" "noauth" {
  project    = var.project_id
  location   = var.region
  service    = "fourkeys-grafana-dashboard"
  role       = "roles/run.invoker"
  members    = ["allUsers"]
  depends_on = [google_cloud_run_service.dashboard]
}