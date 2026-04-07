output "rabbitmq_public_ip" {
  value       = aws_instance.rabbitmq.public_ip
  description = "IP pública del servidor RabbitMQ"
}

output "mongodb_public_ip" {
  value       = aws_instance.mongodb.public_ip
  description = "IP pública del servidor MongoDB"
}

output "worker_public_ip" {
  value       = aws_instance.worker.public_ip
  description = "IP pública del servidor Worker"
}

output "api_public_ips" {
  value       = aws_instance.api[*].public_ip
  description = "IPs públicas de los servidores API"
}

output "alb_dns" {
  value       = aws_lb.alb.dns_name
  description = "URL del Load Balancer"
}