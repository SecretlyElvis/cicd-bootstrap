variable "access_point" {
    description = "File path to be mounted by Jankins DEV/PRD and Nexus for data isolation"
    type = string
}

variable "private_subnets" {
    description = "Subnets for creation of EFS mount targets"
    type = list
    default = []
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