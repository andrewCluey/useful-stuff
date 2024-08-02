packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

/*
What’s happening here:

First, we reference the source block.
This defines details of the source image, creds, Resource groups and image name etc.
It also defines the destination for the end image. This can be a standard Image in an RG or in a Compute Gallery.

We then have the BUILD block, this sets what we will be installing in the new image.
  - We install Chocolatey using the one-liner PowerShell command from the official docs.
  - We copy the packages.config file, an XML manifest containing a list of apps for Chocolatey to install, to the temporary disk D: of the VM. 
  - Then we pass the manifest to the choco install command. When the command exits with the code 3010, a reboot is required. 
  - We make Packer aware of that by passing 3010 to the list of valid_exit_codes.
  - For good measure, we reboot the VM.
  - We run a custom PowerShell script to install the Azure PowerShell modules.

Finally, we generalize the image using Sysprep

*/
# Using Azure CLI for authentication
source "azure-arm" "vm" {
  polling_duration_timeout   = "60m"
  location                   = var.location

  # Packer Computing Resources
  vm_size = "Standard_D2s_v3"

  # WinRM Communicator
  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "5m"
  winrm_username = "packer"

  # Service Principal Authentication
  use_azure_cli_auth = true

  # Source Image
  os_type             = "Windows"
  secure_boot_enabled = true
  security_type       = "TrustedLaunch"
  vtpm_enabled        = true
  # base image options (Azure Marketplace Images only)
  image_publisher    = var.image.publisher # "microsoftvisualstudio"
  image_offer        = var.image.offer # "windowsplustools"
  image_sku          = var.image.sku # "base-win11-gen2"
  image_version      = var.image.version # "latest"

  # Destination Image
  shared_image_gallery_destination {
    resource_group       = var.gallery_resource_group
    gallery_name         = var.gallery_name
    image_name           = var.produced_image_name # "win11-trusted"
    image_version        = var.produced_image_version # "1.0.0"
    storage_account_type = "Standard_LRS"
    target_region {
      name = var.location
    }
  }
}

# Build block
build {
  source "azure-arm.vm" {}

  # Install Chocolatey: https://chocolatey.org/install#individual
  provisioner "powershell" {
    inline = ["Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"]
  }

  # Install Chocolatey packages specified in the manifestr file (packages.config)
  provisioner "file" {
    source      = "../scripts/packages.config"
    destination = "D:/packages.config" 
  }

  provisioner "file" {
    source = "../scripts/comment.cmtx"
    destination = "C:\\windows\\system32\\grouppolicy\\user"
  }

  provisioner "file" {
    source = "../scripts/Registry.pol"
    destination = "C:\\windows\\system32\\grouppolicy\\user"
  }

  provisioner "powershell" {
    inline = ["choco install --confirm D:/packages.config"]
    # See https://docs.chocolatey.org/en-us/choco/commands/install#exit-codes
    valid_exit_codes = [0, 3010]
  }

  provisioner "windows-restart" {}


  # Generalize image using Sysprep
  # See https://www.packer.io/docs/builders/azure/arm#windows
  # See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer#define-packer-template
  provisioner "powershell" {
    inline = [
      "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while ($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}
