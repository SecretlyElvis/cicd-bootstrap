## Variables for IAM_Elements

variable "create_iam" {
    description = "Flag Whether to Create IAM Components (IAM User for EC2 Agent, Instance Profile, etc.) - Not Retuired for NExus"
    type = bool
    default = false
}

variable "assumable_roles" {
    description = "List of Roles in Other Accounts that Can Be Assumed by EC2 Slave Agent Insance Profile"
    type = list(string)
    default = []
}

variable "deployment_role_policy" {
    description = "Policy for Sample Assumable Role in Same Account as CI/CD Platform"
    type = string
}

variable "jenkins_master_policy" {
  description = "Policy for Jenkins Master Host to Stand Up Slave EC2 Agents"
  type = string
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