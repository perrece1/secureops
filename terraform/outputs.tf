output "container_id" {
  description = "ID del contenedor generado por Docker"
  value       = docker_container.api_service.id
}

output "service_url" {
  description = "URL directa para acceder a la API"
  value       = "http://localhost:${var.external_port}"
}
