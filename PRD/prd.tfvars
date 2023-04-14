## Terraform State Variables PEO DEV Account (667873832206)

# Role to assume for execution of infrastructure actions
role_arn = "arn:aws:iam::667873832206:role/OrganizationAccountAccessRole"

# Default Region
region = "ap-southeast-2"

## VPC Configuration

vpc_defs = [ 
    {
        name = "prd-jenkins-dev"
        cidr = "10.16.3.0/24"

        azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
        private_subnets = ["10.16.3.0/27", "10.16.3.32/27", "10.16.3.64/27"]
        public_subnets  = ["10.16.3.128/27", "10.16.3.160/27", "10.16.3.192/27"]

        enable_nat_gateway = true
        enable_vpn_gateway = false
    },
    {
        name = "prd-nexus"
        cidr = "10.16.4.0/24"

        azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
        private_subnets = ["10.16.3.0/27", "10.16.3.32/27", "10.16.3.64/27"]
        public_subnets  = ["10.16.3.128/27", "10.16.3.160/27", "10.16.3.192/27"]

        enable_nat_gateway = false
        enable_vpn_gateway = false
    },
    {
        name = "prd-jenkins-prd"
        cidr = "10.16.5.0/24"

        azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
        private_subnets = ["10.16.3.0/27", "10.16.3.32/27", "10.16.3.64/27"]
        public_subnets  = ["10.16.3.128/27", "10.16.3.160/27", "10.16.3.192/27"]

        enable_nat_gateway = true
        enable_vpn_gateway = false
    }    
]
# VPC CIDR RANGES

# 10.16.3.0/24 - Jenkins DEV
# Public Subnets:
#  - 10.16.3.0/27				
#  - 10.16.3.32/27	
#  - 10.16.3.64/27		
#  - 10.16.3.96/27
# Private Subnets	
#  - 10.16.3.128/27			
#  - 10.16.3.160/27	
#  - 10.16.3.192/27		
#  - 10.16.3.224/27

# 10.16.4.0/24 - Nexus
# Public Subnets:
#  - 10.16.4.0/27				
#  - 10.16.4.32/27	
#  - 10.16.4.64/27		
#  - 10.16.4.96/27
# Private Subnets	
#  - 10.16.4.128/27			
#  - 10.16.4.160/27	
#  - 10.16.4.192/27		
#  - 10.16.4.224/27

# 10.16.5.0/24 - Jenkins PRD
# Public Subnets:
#  - 10.16.5.0/27				
#  - 10.16.5.32/27	
#  - 10.16.5.64/27		
#  - 10.16.5.96/27
# Private Subnets	
#  - 10.16.5.128/27			
#  - 10.16.5.160/27	
#  - 10.16.5.192/27		
#  - 10.16.5.224/27

## Overall

common_tags = {}
