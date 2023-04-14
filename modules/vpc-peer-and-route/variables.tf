variable "jenkins_vpc_id" {
    description = "VPC ID for Jenkins DEV/PRD (requesting VPC)"
    type = string
}

variable "jenkins_vpc_cidr" {
    description = "CIDR Range for Jenkins VPC to add to Route"
    type = string
}

variable "jenkins_route_table_id" {
    description = "The default route table for the Jenkins VPC"
    type = string
}

variable "jenkins_public_rt" {
    description = "List of route table IDs for Jenkins public subnets"
    type = list
}

variable "jenkins_private_rt" {
    description = "List of route table IDs for Jenkins private subnets"
    type = list
}

variable "nexus_vpc_id" {
    description = "Nexus VPC ID (accepting VPC)"
    type = string
}

variable "nexus_vpc_cidr" {
    description = "CIDR Range for Nexus VPC to add to Route"
    type = string
}

variable "nexus_route_table_id" {
    description = "The default route table for the Nexus VPC"
    type = string
}

variable "nexus_public_rt" {
    description = "List of route table IDs for Nexus public subnets"
    type = list
}

variable "nexus_private_rt" {
    description = "List of route table IDs for Nexus private subnets"
    type = list
}

variable "name_prefix" {
    description = "Unique platform prefix for component tagging"
    type = string
}

## Common Tags for All Infrastructure Components
variable "common_tags" {
  description = "Common tags applied to all the resources created in this module"
  type        = map(string)
  default     = {}
}
