variable "vpc_id" {
  description = "VPC ID for Fargate Application Deployment"
  type = string
}

variable "vpc_cidr" {
    description = "CIDR Range for VPC to Use as Source/Target"
    type = string
}

variable "app_type" {
  description = "Label for the Type of Application to Indicate Additional SGs Required"
  type = string
  default = ""
}

variable "app_ports" {
  description = "Host/Container Ports for ALB Target Groups"
  type = list
}

variable "shortname" {
  description = "Distinct Identifier for Fargate Application"
  type = string
  default = ""
}

variable "basename" {
    description = "Prefix for names associated with each component"
    type = string
}

## Common Tags for All Infrastructure Components
variable "common_tags" {
  description = "Common tags applied to all the resources created in this module"
  type        = map(string)
  default     = {}
}

