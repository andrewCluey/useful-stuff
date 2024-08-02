variable "location" {
  type = string
  default = "uksouth"
}

variable "gallery_resource_group" {
  type        = string
  description = "Gallery Resource Group."
  default = "rg-devcenter"
}

variable "gallery_name" {
  type = string
  description = "VM Image Gallery Name."
}

variable "name" {
  type = string
  default = "new-win-11-ent"
}