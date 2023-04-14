variable "docker_image" {
  description = "Docker Image Descriptor for Fargate"
  type = string
}

variable "app_port" {
  description = "Container Port for Application Listener"
  type = string
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

variable "default_security_group_id" {
  description = "Security Group to Assign to Fargate Application"
  type = string  
}

variable "public_subnets" {
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

## Common Tags for All Infrastructure Components
variable "common_tags" {
  description = "Common tags applied to all the resources created in this module"
  type        = map(string)
  default     = {}
}

