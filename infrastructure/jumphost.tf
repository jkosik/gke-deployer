resource "google_compute_instance" "jumphost" {
  name         = "jh"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["jh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {
      // Ephemeral IP
    }

  }

  labels = {
    owner = var.owner
    app  = "jh"
  }

  metadata = {
    ssh-keys = <<EOF
      ${var.user1}:${var.user1_ssh_pubkey}
      ${var.user2}:${var.user2_ssh_pubkey}
    EOF
  }

  service_account {
    email  = data.google_service_account.sa.email
    scopes = ["cloud-platform"]
  }

}

resource "google_compute_firewall" "fwjh" {
  name    = "fwjh"
  network = google_compute_network.network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["jh"]
}

module "gcloud" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 2.0"

  platform = "linux"
  additional_components = ["kubectl", "beta"]

  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "version"
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "version"
}

# Deploy Ops agent for log and metrics collection
module "agent_policy" {
  source     = "terraform-google-modules/cloud-operations/google//modules/agent-policy"
  version    = "0.2.1"

  project_id = var.project_id
  policy_id  = "ops-agents-example-policy"
  agent_rules = [
    {
      type               = "logging"
      version            = "current-major"
      package_state      = "installed"
      enable_autoupgrade = true
    },
    {
      type               = "metrics"
      version            = "current-major"
      package_state      = "installed"
      enable_autoupgrade = true
    },
  ]
  group_labels = [
    {
      owner = "${var.owner}"
      app = "jh"
    }
  ]
  os_types = [
    {
      short_name = "debian"
      version    = "10"
    },
  ]
}