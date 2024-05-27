terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  zone        = "us-central1-a"
  region      = "us-central1"
  project     = "elemental-apex-420520"
  credentials = "elemental-apex-420520-8d3f13306920.json"
}

resource "google_storage_bucket" "task1-static-site" {
  name          = "task1-static-site-osharpe"
  location      = "US"
  force_destroy = true

  # FALSE MEANS THAT THE BUCKET IS NOT LOCKED
  uniform_bucket_level_access = false

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# RESOURCE TO MAKE THIS A PUBLIC BUCKET (ACL => ACCESS CONTROL LIST)
resource "google_storage_bucket_acl" "task1-static-site_acl" {
  bucket         = google_storage_bucket.task1-static-site.name
  predefined_acl = "publicRead"
}

resource "google_storage_bucket_object" "html_files" {
  for_each     = fileset("${path.module}/", "*.html")
  name         = each.value
  source       = "${path.module}/${each.value}"
  bucket       = google_storage_bucket.task1-static-site.name
  content_type = "text/html"
}

resource "google_storage_object_acl" "html_files_acl" {
  for_each       = google_storage_bucket_object.html_files
  bucket         = google_storage_bucket_object.html_files[each.key].bucket
  object         = google_storage_bucket_object.html_files[each.key].name
  predefined_acl = "publicRead"
}

resource "google_storage_bucket_object" "image_files" {
  for_each     = fileset("${path.module}/", "*.jpg")
  name         = each.value
  source       = "${path.module}/${each.value}"
  bucket       = google_storage_bucket.task1-static-site.name
  content_type = "image/jpg"
}

resource "google_storage_object_acl" "image_files_acl" {
  for_each       = google_storage_bucket_object.image_files
  bucket         = google_storage_bucket_object.image_files[each.key].bucket
  object         = google_storage_bucket_object.image_files[each.key].name
  predefined_acl = "publicRead"
}

output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.task1-static-site.name}/index.html"

  depends_on = [
    google_storage_bucket.task1-static-site,
    google_storage_bucket_object.html_files
  ]
}