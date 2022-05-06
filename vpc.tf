// Create VPC
resource "google_compute_network" "vpc" {
 project                 = "heroic-tide-348508"
 name                    = var.vpc-name
 auto_create_subnetworks = "false"
 mtu                     = 1460
}

// Create management Subnet 
resource "google_compute_subnetwork" "subnet" {
 name          = var.management-sub-name
 ip_cidr_range = var.management-subnet_cidr
 network       = var.vpc-name
 depends_on    = [google_compute_network.vpc]
 region        = "us-central1"
 private_ip_google_access = true
}
///////////router for NAT////////////
resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc.id

  bgp {
    asn = 64514
  }
}
/////////////NAT///////////
resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

   subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

// VPC firewall configuration
resource "google_compute_firewall" "firewall" {
  name      = var.firewall-management-name
  network   = google_compute_network.vpc.name
  project   = "heroic-tide-348508"
  direction = "INGRESS"

  # allow {
  #   protocol = "icmp"
  # }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

// Create restricted Subnet  
resource "google_compute_subnetwork" "subnet2" {
 name          = var.restricted-sub-name
 ip_cidr_range = var.restricted-subnet_cidr
 network       = var.vpc-name
 depends_on    = [google_compute_network.vpc]
 region        = "us-central1"
 private_ip_google_access = true
}
