terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.33.1"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}