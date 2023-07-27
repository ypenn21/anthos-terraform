/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
variable "sync_repo" {
  type        = string
  description = "git URL for the repo which will be sync'ed into the cluster via Config Management"
  default = "https://github.com/ypenn21/anthos-config-manage.git"
}

variable "sync_branch" {
  type        = string
  description = "the git branch in the repo to sync"
  default = "main"
}


variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "The zone to host the cluster in (required if is a zonal cluster)"
}
