resource "google_service_account" "SVaccounnt" {
  account_id   = "gcp-terraform"
  display_name = "Service Account"
}
resource "google_project_iam_member" "SVaccounnt_rb" {
  project = "heroic-tide-348508"
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.SVaccounnt.email}"
}

resource "google_compute_instance" "default" {
  name         = "testing"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20220419"
      type  = "pd-standard"
      size  = 10
    }
  }
depends_on = [
    google_compute_network.vpc,google_compute_subnetwork.subnet,google_compute_subnetwork.subnet2,
    google_compute_firewall.firewall,
  ]


  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
    
  }

  
  service_account {
    email  = google_service_account.SVaccounnt.email
    scopes = ["cloud-platform"]
  }
}