variable "vpc_id" {
  description = "ID de la VPC donde se desplegará la infraestructura"
  type        = string
  default     = "vpc-02e4d3356b842dec0"
}

variable "subnets" {
  description = "Lista de subnets para las instancias y el ALB"
  type        = list(string)
  default     = [
    "subnet-0333d9ba77caa1da7", # us-east-1a
    "subnet-04812eca9109443c5", # us-east-1b
    "subnet-0db524d7d314147cf"  # us-east-1c
  ]
}

variable "ami_id" {
  description = "AMI para Amazon Linux 2023"
  type        = string
  default     = "ami-02dfbd4ff395f2a1b"
}

variable "key_name" {
  description = "Nombre de la llave .pem para acceso SSH"
  type        = string
  default     = "martin"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}