terraform {
  required_version = ">= 1.3.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

# Red dedicada para la API
resource "docker_network" "app_network" {
  name   = "secureops_network"
  driver = "bridge"
}

# Despliegue del contenedor de la API
resource "docker_container" "api_service" {
  name  = var.container_name
  image = var.app_image

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 8000
    external = var.external_port
  }

  env = [
    "ENV=production",
    "LOG_LEVEL=info"
  ]

  restart = "unless-stopped"
}
