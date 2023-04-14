## Terraform State
variable "region" {
  description = "AWS region the resources will be deployed to"
  type = string
}

variable "role_arn" {
  description = "AWS region the resources will be deployed to"
  type = string
}

## VPC Configuration
variable "vpc_defs" {
  description = "List of VPC definitions to provision"
  type = list
}

## VPC Peering Connections
variable "peering_pairs" {
  description = "List of VPC Tuples to Peer"
  type = map
}

variable "application" {
  description = "Application Identifier"
  type = string
  default = ""
}

variable "tenant" {
  description = "Tenant Identifier"
  type = string
  default = ""
}

variable "environment" {
  description = "Environment Identifier"
  type = string
  default = ""
}

## Common Tags for All Infrastructure Components
variable "common_tags" {
  description = "Common tags applied to all the resources created in this module"
  type        = map(string)
  default     = {}
}