resource "google_compute_network" "network" {
  name                    = var.project_id
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-${var.region}"
  network       = google_compute_network.network.name
  region        = var.region
  ip_cidr_range = "192.168.16.0/20"
  # defining secondary Pods/SVC IP ranges in GKE resource to avoid complex references
  # secondary_ip_range {
  #     range_name = "secondary-subnet-pods"
  #     ip_cidr_range = var.gke_secondary_subnet_pods
  # } 
  # secondary_ip_range { 
  #     range_name = "secondary-subnet-services"
  #     ip_cidr_range = var.gke_secondary_subnet_services
  # }
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "cloud-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.network.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "cloud-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}