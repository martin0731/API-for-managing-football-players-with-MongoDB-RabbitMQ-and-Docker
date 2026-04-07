# EC2 para la API (2 instancias)
resource "aws_instance" "api" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnets[count.index]
  vpc_security_group_ids = [aws_security_group.api_sg.id]

  iam_instance_profile = "LabInstanceProfile"

  user_data                   = file("${path.module}/scripts/install_api.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "API-Server-${count.index + 1}"
  }
}

# EC2 para MongoDB
resource "aws_instance" "mongodb" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnets[0]
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  
  iam_instance_profile   = "LabInstanceProfile"

  user_data              = file("${path.module}/scripts/install_mongodb.sh")

  tags = { Name = "MongoDB-Server" }
}

# EC2 para RabbitMQ
resource "aws_instance" "rabbitmq" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnets[1]
  vpc_security_group_ids = [aws_security_group.rabbitmq_sg.id]
  
  iam_instance_profile   = "LabInstanceProfile"

  user_data              = file("${path.module}/scripts/install_rabbitmq.sh")

  tags = { Name = "RabbitMQ-Server" }
}

# EC2 para el Worker
resource "aws_instance" "worker" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnets[2]
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  
  iam_instance_profile   = "LabInstanceProfile"

  user_data              = file("${path.module}/scripts/install_worker.sh")

  tags = { Name = "Worker-Server" }
}

# target group
resource "aws_lb_target_group" "tg" {
  name     = "api-target-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200"
  }
}

# conectar api a target group
resource "aws_lb_target_group_attachment" "tg_attach" {
  count            = 2
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.api[count.index].id
  port             = 8000
}

# load balancer
resource "aws_lb" "alb" {
  name               = "api-alb"
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name = "API-ALB"
  }
}

# listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
