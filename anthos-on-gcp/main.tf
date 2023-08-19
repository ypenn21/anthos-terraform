resource "google_container_cluster" "cluster" {
  count              = 2
  name               = "asm-cluster-${count.index}"
  location           = var.zone
  initial_node_count = 1
  provider           = google-beta
  resource_labels    = { mesh_id : "proj-${data.google_project.project.number}" }
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }
  node_config {
    machine_type = "e2-standard-4"
  }
  depends_on = [
    google_project_service.project
  ]
}
data "google_project" "project" {
  project_id = var.project_id
}
resource "google_gke_hub_membership" "membership" {
  count = 2
  membership_id = "membership-${count.index}"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster[count.index].id}"
    }
  }
  provider = google-beta
}

#resource "google_gke_hub_membership" "membership2" {
#  provider = google-beta
#  membership_id = "epam-member2"
#  endpoint {
#    gke_cluster {
#      resource_link = "//container.googleapis.com/${google_container_cluster.cluster2.id}"
#    }
#  }
#}

resource "google_project_service" "project" {
  project = var.project_id
  service = "mesh.googleapis.com"

  disable_dependent_services = true
}
