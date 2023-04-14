## Terraform State Variables PEO DEV Account (667873832206)

# Role to assume for execution of infrastructure actions
role_arn = "arn:aws:iam::123456789012:role/TerraformDeployRole"

# Default Region
region = "ap-southeast-2"

# Naming Components
application           = "cicd"                     
tenant                = "nrl"                     
environment           = "dev" 

###################
## Configure 3x VPC
##
## 1) Jenkins DEV
## 2) Nexus
## 3) Jenkins PRD

vpc_defs = [ 
    {
        # JENKINS DEV VPC and APP
        name = "jdev"
        cidr = "10.16.3.0/24"

        azs             = ["ap-southeast-2a", "ap-southeast-2b"]
        private_subnets = ["10.16.3.0/27", "10.16.3.32/27"]
        public_subnets  = ["10.16.3.128/27", "10.16.3.160/27"]

        enable_nat_gateway = true
        single_nat_gateway = true
        one_nat_gateway_per_az = false

        access_point = "/efs/jenkins_dev"

        docker_image = "jenkins/jenkins:lts-jdk11"
        app_port = 8080
        health_check_path = "/login"
        container_mount = "/var/jenkins_home"

        internal_facing = false
    },
    {
        # NEXUS VPC and APP
        name = "nxs"        
        cidr = "10.16.4.0/24"

        azs             = ["ap-southeast-2b", "ap-southeast-2c"]
        private_subnets = []
        public_subnets  = ["10.16.4.128/27", "10.16.4.160/27"]

        enable_nat_gateway = false 
        single_nat_gateway = false 
        one_nat_gateway_per_az = false

        access_point = "/efs/nexus"

        docker_image = "sonatype/nexus3:latest"
        app_port = 8081
        health_check_path = "/service/rest/v1/status" 
        container_mount = "/opt/sonatype/sonatype-work/nexus3"

        internal_facing = true     
    },
#    {
#        # JENKINS PRD VPC and APP
#        name = "jprd"
#        cidr = "10.16.5.0/24"
#
#        azs             = ["ap-southeast-2a", "ap-southeast-2c"]
#        private_subnets = ["10.16.5.0/27", "10.16.5.32/27"]
#        public_subnets  = ["10.16.5.128/27", "10.16.5.160/27"]
#
#        enable_nat_gateway = true
#        single_nat_gateway = true
#        one_nat_gateway_per_az = false
#
#        access_point = "/efs/jenkins_prd"
#
#        docker_image = "jenkins/jenkins:lts-jdk11"
#        app_port = 8080
#        health_check_path = "/login"
#        container_mount = "/var/jenkins_home"
#
#        internal_facing = false
#    }    
]

#######################################################################
## VPC Peering Connections (Jenkins DEV -> Nexus, Jenkins PRD -> Nexus)
## Refs to index values in 'vpc_defs' array

peering_pairs = {

    jdev_to_nexus = [0, 1]
#    jprd_to_nexus = [2, 1]

}    

##########
## Overall

common_tags = {}

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
