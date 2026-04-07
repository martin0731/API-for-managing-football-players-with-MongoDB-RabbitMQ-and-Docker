# 🚀 AWS Microservices Infrastructure with Terraform

Este repositorio contiene la configuración de **Infraestructura como Código (IaC)** para desplegar una arquitectura de microservicios desacoplada en AWS. El sistema gestiona datos de futbolistas utilizando una API, un broker de mensajería y una base de datos NoSQL.

## 🏗️ Arquitectura del Sistema

La solución implementa un modelo de **Alta Disponibilidad** y **Service Discovery** dinámico:

* **Capa de Acceso:** Application Load Balancer (ALB) que distribuye tráfico HTTP.
* **Capa de Aplicación:** 2 instancias EC2 corriendo la API (FastAPI) con Docker Compose.
* **Capa de Mensajería:** RabbitMQ para la comunicación asíncrona entre servicios.
* **Capa de Datos:** MongoDB para el almacenamiento persistente de documentos.
* **Capa de Procesamiento:** Worker independiente que consume tareas de la cola.
* **Service Discovery:** Las instancias publican y consultan sus IPs privadas mediante **AWS SSM Parameter Store**.

## 🛡️ Diseño de Red (Security Groups)

Se aplica el principio de **Mínimo Privilegio**:
1.  **ALB-SG:** Abre puerto 80 al mundo.
2.  **API-SG:** Solo acepta tráfico del ALB (puerto 8000) y SSH (22).
3.  **RabbitMQ-SG:** Abre puerto 5672 (interno), 15672 (Panel Web) y SSH (22).
4.  **MongoDB-SG:** Abre puerto 27017 (interno/Compass) y SSH (22).
5.  **Worker-SG:** Solo SSH (22) para auditoría de logs.

---

## 🛠️ Comandos de Gestión

Se puede utilizar **Terraform** u **OpenTofu** para administrar el ciclo de vida de la infraestructura.

### 1. Inicialización
Prepara el directorio de trabajo y descarga los providers necesarios.
```bash
terraform init
```

### 2. Planificación
Previsualiza los cambios y guárdalos en un archivo de plan para asegurar un despliegue controlado.
```bash
terraform plan -out=project.tfplan
```

### 3. Despliegue
Aplica los cambios definidos en el archivo del plan.
```bash
terraform apply project.tfplan
```

### 4. Destrucción
Elimina todos los recursos creados en AWS para evitar costos innecesarios.
```bash
terraform destroy
```

### 🔗 Endpoints de Verificación
Una vez el despliegue sea exitoso (Estado: Healthy en el Target Group), utiliza estas rutas para validar los servicios:

| Servicio | URL / Protocolo |
|----------|----------------|
| API Documentation | `http://<alb_dns>/docs` |
| RabbitMQ Dashboard | `http://<rabbitmq_public_ip>:15672` |
| MongoDB Compass | `mongodb://admin:password123@<mongodb_public_ip>:27017/` |