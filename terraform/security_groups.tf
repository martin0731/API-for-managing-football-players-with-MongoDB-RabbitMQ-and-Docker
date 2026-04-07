# balanceador de carga
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Acceso publico HTTP para el Load Balancer"
  vpc_id      = var.vpc_id

  # Acceso web estándar desde cualquier lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# api 
resource "aws_security_group" "api_sg" {
  name        = "api-sg"
  description = "Permite trafico solo desde el ALB"
  vpc_id      = var.vpc_id

  # Seguridad Perimetral: Solo acepta trafico que venga del Security Group del ALB
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Acceso SSH para gestion desde tu MacBook
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# rabbitMQ
resource "aws_security_group" "rabbitmq_sg" {
  name        = "rabbitmq-sg"
  description = "Mensajeria interna y panel web de administracion"
  vpc_id      = var.vpc_id

  # Puerto 5672: Comunicacion interna de datos (AMQP) entre API y Worker
  ingress {
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.api_sg.id, aws_security_group.worker_sg.id]
  }

  # Puerto 15672: Interfaz Web para ver graficas en el navegador
  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# mongoDB
resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb-sg"
  description = "Acceso a base de datos para la App y Compass"
  vpc_id      = var.vpc_id

  # Acceso interno desde la API y el Worker
  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.api_sg.id, aws_security_group.worker_sg.id]
  }

  # Acceso externo para visualizar datos desde MongoDB Compass
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# worker
resource "aws_security_group" "worker_sg" {
  name        = "worker-sg"
  description = "Instancia de procesamiento sin puertos publicos"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}