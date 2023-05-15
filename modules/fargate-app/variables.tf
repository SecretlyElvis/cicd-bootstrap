variable "docker_image" {
  description = "Docker Image Descriptor for Fargate"
  type = string
}

variable "app_ports" {
  description = "Host/Container Ports for ALB Target Groups"
  type = list
}

variable "port_mappings" {
  description = "List of mappings from Host Port -> Container Port"
  type = list
  
}

variable "port_tg" {
  description = "Mappings of Host/Container Ports to Target Group List Index"
  type = map
}

variable "container_mount" {
  description = "File Path Inside Container to Mount EFS Access Point"
  type = string
}

variable "health_check_path" {
  description = "Path to Use in Load Balancer Health Check"
  type = string
}

variable "file_system_id" {
  description = "EFS Filesystem to Mount to Fargate Application"
  type = string
}

variable "access_point_id" {
  description = "Access Point in EFS Filesystem to Mount Inside Container"
  type = string
}

variable "ecs_sg_id" {
  description = "Security Group for ECS Service/Fargate"
  type = string  
}

variable "alb_sg_id" {
  description = "Security Group for Application Load Balancer"
  type = string  
}

variable "default_security_group_id" {
  description = "Security Group to Assign to Fargate Application"
  type = string  
}

variable "public_subnets" {
  description = "Subnets for Application Load Balancer Deployment"
  type = list
}

variable "private_subnets" {
  description = "Subnets for Fargate Application Deployment"
  type = list
}

variable "vpc_id" {
  description = "VPC ID for Fargate Application Deployment"
  type = string
}

variable "basename" {
  description = "Combination of Application, Tenant and Environment"
  type = string
  default = "app-tnt-env"
}

variable "shortname" {
  description = "Distinct Identifier for Fargate Application"
  type = string
  default = ""
}

## Hosted Zone Name to Pre-pend with Subdomains
variable "hz_name" {
  description = "Name of Hosted Zone in Which to Create Subdomain Records"
  type = string
  
}

variable "cert_arn" {
  description = "ARN of Wildcard Certificate for the Account"
  type = string
}

variable "subdomains" {
  description = "List of Subdomains to Pre-pend to Hosted Zone Name as Alias Records"
  type = list(string)
}

## Common Tags for All Infrastructure Components
variable "common_tags" {
  description = "Common tags applied to all the resources created in this module"
  type        = map(string)
  default     = {}
}

