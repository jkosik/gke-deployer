resource "google_container_cluster" "gke_cluster" {
  name       = var.gke_cluster_name
  location   = var.zone # var.region for HA, var.zone to save resources
  network    = google_compute_network.network.name
  subnetwork = google_compute_subnetwork.subnet.name
  ip_allocation_policy { # enables IP aliasing needed for VPC-native clusters to use http(s) internal LB
    cluster_ipv4_cidr_block  = var.gke_secondary_subnet_pods
    services_ipv4_cidr_block = var.gke_secondary_subnet_services
  }
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "GKE Public access from"
      cidr_block   = var.gke_public_access_from
    }
  }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.gke_master_ipv4_cidr
  }

  remove_default_node_pool = true
  initial_node_count       = 1 # Ephemeral setting. Deleting default node pool.
}

resource "google_container_node_pool" "nodepool" {
  name       = "${var.gke_cluster_name}-nodepool"
  location   = var.zone # var.region for HA, var.zone to save resources
  cluster    = google_container_cluster.gke_cluster.name
  node_count = var.gke_node_count

  node_config {
    preemptible  = true
    machine_type = var.gke_machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = data.google_service_account.sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

