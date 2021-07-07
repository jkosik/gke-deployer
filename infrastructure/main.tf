terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.74.0"
    }
  }

  required_version = "1.0.1"

  backend "gcs" {
    bucket = "tfstate_workload-318005_gke-deployer" # var not supported here, template instead
    prefix = "dev"                                  # var not supported here, template instead
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

