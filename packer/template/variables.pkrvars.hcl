# This is the packer 'answers' file

gallery_name           = "acggallery"
gallery_resource_group = "rg-devcenter"
location               = "uksouth"
image = {
  publisher = "microsoftvisualstudio"
  offer     = "windowsplustools"
  sku       = "base-win10-gen2"
  version   = "latest"
}
produced_image_name = "win10-db-base"
produced_image_version = "1.0.0"   # consider setting this dynamically in cmd line via pipeline vars.