locals {
  project         = "gkee-ff-2"
  region          = "us-central1"
  zone            = "us-central1-c"
  view_principal  = "gkee-fishfood@google.com" # change this, normally a group
  num_clusters    = 2
  node_count      = 3
  namespace_names = ["acme-anvils", "acme-explosives"]
}

provider "google" {
  project = local.project
  region  = local.region
  zone    = local.zone
}

resource "random_id" "rand" {
  byte_length = 4
}

resource "google_container_cluster" "acme_clusters" {
  count              = local.num_clusters
  name               = "gkee-fleet-tf-${random_id.rand.hex}-${count.index}"
  initial_node_count = local.node_count
  location           = local.zone
}

# for now, explicitly register bc BiF is not yet implemented. (b/264590261)
# also, need to support region memberships (b/300473592)
resource "google_gke_hub_membership" "acme_memberships" {
  count         = local.num_clusters
  membership_id = google_container_cluster.acme_clusters[count.index].name
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.acme_clusters[count.index].id}"
    }
  }
}

resource "google_gke_hub_scope" "acme_scope" {
  scope_id = "gkee-fleet-tf-${random_id.rand.hex}"
}

resource "google_gke_hub_membership_binding" "acme_scope_clusters" {
  count                 = local.num_clusters
  membership_binding_id = "${google_gke_hub_scope.acme_scope.scope_id}-${count.index}"
  scope                 = google_gke_hub_scope.acme_scope.id
  membership_id         = google_gke_hub_membership.acme_memberships[count.index].membership_id
  location              = "global"
}

resource "google_gke_hub_namespace" "acme_scope_namespaces" {
  count              = length(local.namespace_names)
  scope_namespace_id = element(local.namespace_names, count.index)
  scope_id           = google_gke_hub_scope.acme_scope.scope_id
  scope              = google_gke_hub_scope.acme_scope.id
}

resource "google_gke_hub_scope_rbac_role_binding" "acme_rolebinding" {
  scope_rbac_role_binding_id = "acme-dev-viewers"
  scope_id                   = google_gke_hub_scope.acme_scope.scope_id
  user                       = local.view_principal
  role {
    predefined_role = "VIEW"
  }
}


## TODO add workload identity bindings for metrics service accounts

# there are issues with regionalized members' features, too (b/300473592)
resource "google_gke_hub_feature_membership" "acme_scope_clusters_policy" {
  count = local.num_clusters
  location   = "global"
  feature    = "configmanagement"
  membership = google_gke_hub_membership.acme_memberships[count.index].membership_id

  configmanagement {
    policy_controller {
      enabled                    = true
      referential_rules_enabled  = true
      template_library_installed = true
    }
  }
}

