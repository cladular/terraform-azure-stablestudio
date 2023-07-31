provider "azurerm" {
  features {}
}

locals {
  port = 3000
  commands = [
    "git clone https://github.com/Stability-AI/StableStudio.git",
    "cd StableStudio",
    "yarn",
    "yarn dev --host"
  ]
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.deployment_name}-${var.location}"
  location = var.location
}

resource "azurerm_container_group" "this" {
  name                = "aci-${var.deployment_name}-${var.location}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "Public"
  os_type             = "Linux"
  dns_name_label      = "${var.deployment_name}-${var.location}"

  container {
    name   = "${var.deployment_name}-container"
    image  = "node:latest"
    cpu    = "2"
    memory = "4"

    commands = [
      "sh",
      "-c",
      join(" && ", local.commands)
    ]

    ports {
      port     = local.port
      protocol = "TCP"
    }
  }
}
