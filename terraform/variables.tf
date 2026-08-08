variable "container_name" {
  description = "Nombre del contenedor de la API"
  type        = string
  default     = "secureops-api-container"
}

variable "app_image" {
  description = "Imagen Docker de la aplicación"
  type        = string
  default     = "secureops-api:1.0.0"
}

variable "external_port" {
  description = "Puerto expuesto en la máquina local"
  type        = number
  default     = 8000
}
