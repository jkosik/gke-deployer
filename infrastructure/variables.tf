variable "environment" {
  description = "environment"
}

variable "project_id" {
  description = "project id"
}

variable "owner" {
  description = "Project owner"
}

variable "region" {
  description = "GCP Region"
}

variable "zone" {
  description = "GCP Zone"
}

variable "subnet_cidr_range" {
  description = "Subnet CIDR range"
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
}

variable "gke_secondary_subnet_pods" {
  description = "Subnet for GKE Pods"
}

variable "gke_secondary_subnet_services" {
  description = "Subnet for GKE Services"
}

variable "gke_master_ipv4_cidr" {
  description = "CIDR for Master nodes"
}

variable "gke_node_count" {
  description = "GKE node count"
}

variable "gke_machine_type" {
  description = "GKE machine type"
}

variable "gke_public_access_from" {
  description = "Authorized externqal networks"
}

variable "user1" {
  description = "User1"
}

variable "user1_ssh_pubkey" {
  description = "User1 SSH public key"
}

variable "user2" {
  description = "User2"
}

variable "user2_ssh_pubkey" {
  description = "User2 SSH public key"
}






