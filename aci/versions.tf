terraform {
  required_providers {
    aci = {
      source = "terraform-providers/aci"
      version = "~> 0.3.4"
    }
  }
  required_version = ">= 0.13"
}