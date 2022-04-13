terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.15.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  gcloud_container_registry_prefix = "eu.gcr.io/${var.project_id}"
  gcp_service_list = [
    "containerregistry.googleapis.com",
    "run.googleapis.com"
  ]
}

resource "google_project_service" "gcp_services" {
  for_each = toset(local.gcp_service_list)
  project  = var.project_id
  service  = each.key
}

module "mirror" {
  source        = "neomantra/mirror/docker"
  version       = "0.4.0"
  image_name    = "unipipe-service-broker"
  image_tag     = var.unipipe_version
  source_prefix = "ghcr.io/meshcloud"
  dest_prefix   = local.gcloud_container_registry_prefix
  depends_on = [
    google_project_service.gcp_services
  ]
}

resource "tls_private_key" "unipipe_git_ssh_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

# setup a random password for the OSB instance
resource "random_password" "unipipe_basic_auth_password" {
  length  = 64
  special = false
}

resource "google_cloud_run_service" "default" {
  name     = var.cloudrun_service_name
  project  = var.project_id
  location = var.region

  template {
    spec {
      containers {
        image = module.mirror.dest_full
        ports {
          name           = "http1"
          container_port = 8075
        }
        env {
          name  = "GIT_REMOTE"
          value = var.unipipe_git_remote
        }
        env {
          name  = "GIT_REMOTE_BRANCH"
          value = var.unipipe_git_branch
        }
        env {
          name  = "GIT_SSH_KEY"
          value = tls_private_key.unipipe_git_ssh_key.private_key_pem
        }
        env {
          name  = "APP_BASIC_AUTH_USERNAME"
          value = var.unipipe_basic_auth_username
        }
        env {
          name  = "APP_BASIC_AUTH_PASSWORD"
          value = random_password.unipipe_basic_auth_password.result
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  autogenerate_revision_name = true
}

# UniPipe uses basic auth, therefore we use the noauth policy for CloudRun
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
