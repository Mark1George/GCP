resource "google_container_cluster" "app_cluster" {
  name     = "app-cluster"
  location = "us-central1-b"

   depends_on = [
    google_compute_network.vpc ,google_compute_subnetwork.subnet ,google_compute_subnetwork.subnet2,
    google_compute_firewall.firewall,
    ]

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    # cluster_ipv4_cidr_block = var.pods_ipv4_cidr_block
    # services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }
  network = var.vpc-name
  subnetwork = var.restricted-sub-name

  logging_service = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  

   master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.management-subnet_cidr
      display_name = "Management CIDR"
    }
  }


  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "192.168.1.0/28"
  }

  release_channel {
      channel = "STABLE"
  }

#   addons_config {
#     // Enable network policy (Calico)
#     network_policy_config {
#         disabled = false
#       }
#   }

#   /* Enable network policy configurations (like Calico).
#   For some reason this has to be in here twice. */
#   network_policy {
#     enabled = "true"
#   }

#   workload_identity_config {
#     identity_namespace = format("%s.svc.id.goog", var.project_id)
#   }
}

resource "google_container_node_pool" "app_cluster_linux_node_pool" {
  name           = "${google_container_cluster.app_cluster.name}--linux-node-pool"
  location       = google_container_cluster.app_cluster.location
#   node_locations = var.node_zones
  cluster        = google_container_cluster.app_cluster.name
  node_count     = 3

  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }
  max_pods_per_node = 100

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    disk_size_gb = 10

    service_account = google_service_account.SVaccounnt.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    labels = {
      cluster = google_container_cluster.app_cluster.name
    }

    # shielded_instance_config {
    #   enable_secure_boot = true
    # }

    # // Enable workload identity on this node pool.
    # workload_metadata_config {
    #   node_metadata = "GKE_METADATA_SERVER"
    # }

    # metadata = {
    #   // Set metadata on the VM to supply more entropy.
    #   google-compute-enable-virtio-rng = "true"
    #   // Explicitly remove GCE legacy metadata API endpoint.
    #   disable-legacy-endpoints = "true"
    # }
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 1
  }
}
