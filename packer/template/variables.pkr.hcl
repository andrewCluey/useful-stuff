variable "location" {
  type    = string
  default = "uksouth"
}

variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = <<EOF
    An object to showing the image that will be used as the base image for htis new version.
    details can be found through AZ CLi commands:
      az vm image list-offers --location uksouth --publisher microsoftvisualstudio --output table
    then..
      az vm image list-skus --location uksouth --offer windowsplustools --publisher microsoftvisualstudio --output table
    Alternatively, images can be filtered in the Azure portal marketplace.

EOF
}

variable "gallery_resource_group" {
  type        = string
  description = "Gallery Resource Group."
  default     = "rg-devbox"
}

variable "gallery_name" {
  type        = string
  description = "VM Image Gallery Name."
}

variable "produced_image_name" {
  type        = string
  description = "The name of the new image that will be produced."
}

variable "produced_image_version" {
  type        = string
  description = "The semantic version of the new image."
  default     = "1.0.0"
}