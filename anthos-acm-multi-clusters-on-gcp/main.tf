data "google_project" "project" {
  project_id = var.project_id
}

resource "google_container_cluster" "cluster" {
  name               = "epam-cluster"
  location           = var.zone
  initial_node_count = 1
  provider           = google-beta
  resource_labels    = { epam : "1" }
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }
  node_config {
    machine_type = "e2-standard-4"
  }
}

resource "google_container_cluster" "cluster2" {
  name               = "epam-cluster2"
  location           = var.zone
  initial_node_count = 1
  provider           = google-beta
  resource_labels    = { epam : "1" }
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }
  node_config {
    machine_type = "e2-standard-4"
  }
}

resource "google_gke_hub_membership" "membership" {
  provider = google-beta
  membership_id = "epam-member"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster.id}"
    }
  }
}

resource "google_gke_hub_membership" "membership2" {
  provider = google-beta
  membership_id = "epam-member2"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster2.id}"
    }
  }
}

resource "google_gke_hub_feature" "configmanagement_acm_feature" {
  name     = "configmanagement"
  location = "global"
  provider = google-beta
}

resource "google_gke_hub_feature_membership" "feature_member" {
  provider   = google-beta
  location   = "global"
  feature    = "configmanagement"
  membership = google_gke_hub_membership.membership.membership_id
  configmanagement {
    version = "1.15.2"
    config_sync {
      source_format = "hierarchy"
      git {
        sync_repo   = var.sync_repo
        sync_branch = var.sync_branch
        secret_type = "none"
        policy_dir = "config"
      }
    }
    policy_controller {
      enabled                    = true
      template_library_installed = true
      referential_rules_enabled  = true
    }
  }
  depends_on = [
    google_gke_hub_feature.configmanagement_acm_feature
  ]
}


resource "google_gke_hub_feature_membership" "feature_member2" {
  provider   = google-beta
  location   = "global"
  feature    = "configmanagement"
  membership = google_gke_hub_membership.membership2.membership_id
  configmanagement {
    version = "1.15.2"
    config_sync {
      source_format = "hierarchy"
      git {
        sync_repo   = var.sync_repo
        sync_branch = var.sync_branch
        secret_type = "none"
        policy_dir = "config"
      }
    }
    policy_controller {
      enabled                    = true
      template_library_installed = true
      referential_rules_enabled  = true
    }
  }
  depends_on = [
    google_gke_hub_feature.configmanagement_acm_feature
  ]
}
