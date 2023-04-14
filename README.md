# Overview

This repository contains Terraform definitions for repeated AWS infrastructure to be deployed across multiple accounts.    

## Structure of Contents
 
There are two categories of files in the repo: **Environment Definitions** and **Configuration Sets**

### Environment Definitions

Exist in the top level directory and have names such as 'BAU_ENV.tfvars'.  They must contain the following (at minimum):

* `bucket`: name of the bucket to hold the Terraform state files.  By convention, they are named as '<account_number>-state', *i.e. "566933467089-state"*
* `region`: region for the account, *i.e. "ap-southeast-2"*
* `role_arn`: role to be assumed by Terraform when executing commands, *i.e. "arn:aws:iam::566933467089:role/terraform_role"*

Sample:

```
# Variables Specific to BAU_DEV Account (566933467089)

# Backend State Destinatino
bucket = "566933467089-state"
region = "ap-southeast-2"

# Role to assume for execution of infrastructure actions
role_arn = "arn:aws:iam::566933467089:role/terraform_role"
```

### Configuration Sets

Exist within their own named directories and represent a bundle of infrastructure that will be deployed together.  These directories can contain any Terraform definition files desired, but must include the following (at minimum):

* A `provider.tf` file with the following contents:
```
terraform {
  backend "s3" {
    key = "<State File Name>.tfstate"
  }
}

provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn     = "${var.role_arn}"
    session_name = "SESSION_NAME"
    external_id  = "EXTERNAL_ID"
  }
}
```
 
Where `<State File Name>` is a unique name identifying the Terraform state file for this bundle, *i.e. "Global_Roles.tfstate"*

* A `varialbes.tf` file identifying which variables will be linked from the Environemnt Definitions.  Example:

```
# Location Variable
variable "region" {
  description = "Variable descibes the AWS region the resources will be deployed to"
}

# Role variables
variable "principal_arns" {
  description = "ARN of master billing account which can assume all configured roles"
}

variable "role_arn" {
  description = "Role to be assumed for execution of tasks"
}
```

## Usage

### Prerequisites

The repository is designed to be run from the command line or automated via an automated ceployment tool (such as Jenkins).  Prior to running any commands, ensure that you have:

* AWS CLI Credentials (Access Key and Secret Key) for an IAM user that has permissions to assume the role defined in the Environment Definition
* The role in the target environment must have a trust relationship with the IAM user defined above
* An S3 bucket in the target account to hold the Terraform state file (see 'Environment Definitions' above)
* Terraform installed on the local machine or within a Docker container

### Command Execution

```
Usage:
  ./tf-run <Terraform command> <Target AWS Account> <Configuration Directory>

Where:
   * Terraform command == init|plan|apply|destroy|*
   * Target AWS Account == BAU_DEV|CICD_NONPROD|AWS_DEV (configuration must exist, i.e. BAU_DEV.tfvars)
   * Configuration Directory == Configuration set, such as 'Global_Roles'

Example:
   ./tf-run init BAU_DEV Global_Roles
```
