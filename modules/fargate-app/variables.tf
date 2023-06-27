variable "docker_image" {
  description = "Docker Image Descriptor for Fargate"
  type = string
}

variable "command" {
  description = "Command-line Arguments to Pass to 'docker run' Post Image Name (equivalent to 'CML')"
  type = list(string)
  default = []
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

variable "create_iam" {
  description = "Boolean Flag Whether to Create IAM Components ('true' for Jenkins Stacks)"
  type = bool
  default = false
}

variable "iam_components" {
  description = "Eleemnts Used for Creating IAM Users and Roles For Jenkins"
  type = map(string)
  default = {}
}

variable "assumable_roles" {
  description = "List of Role ARNs in Other Accounts that can be Assumed by Jenkins Slave Agents"
  type = list 
  default = []
}

variable "task_role" {
  description = "Flag to determine whether to create/attach a Task Role for Fargate"
  type = bool
  default = false
}

variable "task_role_policy" {
  description = "Policy for Fargate Task Role -- Can Be Used to Enable Docker Exec into the Container"
  type = string
  default = ""
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

