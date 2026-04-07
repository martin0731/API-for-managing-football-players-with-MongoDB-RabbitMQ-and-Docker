# RabbitMQ 
resource "aws_ssm_parameter" "rabbitmq_ip" {
  name        = "/message-queue/dev/rabbitmq/public_ip"
  type        = "String"
  value       = aws_instance.rabbitmq.public_ip
  description = "Public IP for RabbitMQ Server"
}

# API 
resource "aws_ssm_parameter" "api_ip" {
  name        = "/message-queue/dev/api/public_ip"
  type        = "String"
  value       = aws_instance.api[0].public_ip
  description = "Public IP for Docker API Server (Instance 1)"
}

# Worker 
resource "aws_ssm_parameter" "worker_ip" {
  name        = "/message-queue/dev/worker/public_ip"
  type        = "String"
  value       = aws_instance.worker.public_ip
  description = "Public IP for Async Worker Server"
}

# MongoDB 
resource "aws_ssm_parameter" "mongodb_ip" {
  name        = "/message-queue/dev/mongodb/public_ip"
  type        = "String"
  value       = aws_instance.mongodb.public_ip
  description = "Public IP for MongoDB Server"
}

resource "aws_ssm_parameter" "mongodb_private_ip" {
  name        = "/message-queue/dev/mongodb/private_ip"
  type        = "String"
  value       = aws_instance.mongodb.private_ip
  description = "Private IP for MongoDB (tráfico VPC instancia a instancia)"
}

resource "aws_ssm_parameter" "rabbitmq_private_ip" {
  name        = "/message-queue/dev/rabbitmq/private_ip"
  type        = "String"
  value       = aws_instance.rabbitmq.private_ip
  description = "Private IP del host RabbitMQ (puerto 5672 en el EC2)"
}
