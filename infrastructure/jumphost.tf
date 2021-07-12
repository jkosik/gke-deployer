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
    app   = "jh"
  }

  metadata = {
    ssh-keys = <<EOF
      ${var.user1}:${var.user1_ssh_pubkey}
      ${var.user2}:${var.user2_ssh_pubkey}
    EOF
  }

  service_account {
    email  = data.google_service_account.sa.email
    scopes   = ["cloud-platform"]
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

