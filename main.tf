/**
 * Copyright 2021 Google LLC
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

resource "google_compute_global_address" "global" {
  for_each = toset(var.global_addresses)
  project  = var.project_id
  name     = each.value
}

resource "google_compute_address" "external" {
  for_each     = var.external_addresses
  project      = var.project_id
  name         = each.key
  description  = "Terraform managed."
  address_type = "EXTERNAL"
  region       = each.value
  # labels       = lookup(var.external_address_labels, each.key, {})
}

resource "google_compute_address" "internal" {
  for_each     = var.internal_addresses
  project      = var.project_id
  name         = each.key
  description  = "Terraform managed."
  address_type = "INTERNAL"
  region       = each.value.region
  subnetwork   = each.value.subnetwork
  address      = try(var.internal_addresses_config[each.key].address, null)
  network_tier = try(var.internal_addresses_config[each.key].tier, null)
  purpose      = try(var.internal_addresses_config[each.key].purpose, null)
  # labels       = lookup(var.internal_address_labels, each.key, {})
}

resource "google_compute_global_address" "psc" {
  for_each     = var.psc_addresses
  project      = var.project_id
  name         = each.key
  description  = "Terraform managed."
  address_type = "INTERNAL"
  network      = each.value.network
  address      = try(each.value.address, null)
  purpose      = "PRIVATE_SERVICE_CONNECT"
  # labels       = lookup(var.internal_address_labels, each.key, {})
}
