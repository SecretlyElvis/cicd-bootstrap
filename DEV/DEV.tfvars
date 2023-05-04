## Terraform State Variables PEO DEV Account (667873832206)

# Role to assume for execution of infrastructure actions
role_arn = "arn:aws:iam::667873832206:role/OrganizationAccountAccessRole"

# Default Region
region = "ap-southeast-2"

# Hosted Zone Name
hz_name = "667873832206.accounts.gentrack.io"

# Wildcard Certificate ARN
cert_arn = "arn:aws:acm:ap-southeast-2:667873832206:certificate/88fbdb44-26d4-4c8b-ae48-470dfd2ea8f8"

# Naming Components
application   = "cicd"                     
tenant        = "peo"                     
environment   = "dev" 

# Create IAM EC2 Agent Policy, Instance Profile
create_iam    = true

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

        docker_image = "jenkins/jenkins:2.400-jdk11"
        app_ports = [ 8080 ]
        subdomains = [ "jenkinsdev" ]
        health_check_path = "/login"
        container_mount = "/var/jenkins_home"
        port_mappings = [
            {
            containerPort = 8080
            hostPort      = 8080
            }
        ]
        port_tg = {
            8080 = 0
        }

    },
    {
        # NEXUS VPC and APP
        name = "nxs"        
        cidr = "10.16.4.0/24"

        azs             = ["ap-southeast-2b", "ap-southeast-2c"]
        private_subnets = ["10.16.4.0/27", "10.16.4.32/27"]
        public_subnets  = ["10.16.4.128/27", "10.16.4.160/27"]

        enable_nat_gateway = true 
        single_nat_gateway = true 
        one_nat_gateway_per_az = false

        access_point = "/efs/nexus"

        docker_image = "sonatype/nexus3:latest"
        app_ports = [ 8081, 8082 ]
        subdomains = [ "nexus", "docker" ]
        health_check_path = "/service/rest/v1/status" 
        container_mount = "/opt/sonatype/sonatype-work/nexus3"
        port_mappings = [
            {
            containerPort = 8081
            hostPort      = 8081
            },
            {
            containerPort = 8082
            hostPort      = 8082
            }            
        ]
        port_tg = {
            8081 = 0
            8082 = 1
        }
   
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
#        app_ports = [ 8080 ]
#        subdomains = [ "jenkinsprd" ]
#        alt_port = -1
#        health_check_path = "/login"
#        container_mount = "/var/jenkins_home"
#        port_mappings = [
#            {
#            containerPort = 8080
#            hostPort      = 8080
#            }
#        ]
#        port_tg = {
#            8080 = 0
#        }
#    }    
]

#######################################################################
## VPC Peering Connections (Jenkins DEV -> Nexus, Jenkins PRD -> Nexus)
## Refs to index values in 'vpc_defs' array

peering_pairs = {

#    jdev_to_nexus = [0, 1]
#    jprd_to_nexus = [2, 1]

}    

#################
## IAM Components

# Instance Profile Policy
# (Role ARNs in other accounts that can be assumed by the EC2 Slave Agent)

assumable_roles = [ "arn:aws:iam::667873832206:role/OrganizationAccountAccessRole" ]

# Assumable Role Policy

deployment_role_policy = <<ARP
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SampleAssumableRolePolicy",
            "Effect": "Allow",            
            "Action": [
                "iam:*",
                "s3:*",
                "dynamodb:*",
                "organizations:DescribeAccount",
                "organizations:DescribeOrganization",
                "organizations:DescribeOrganizationalUnit",
                "organizations:DescribePolicy",
                "organizations:ListChildren",
                "organizations:ListParents",
                "organizations:ListPoliciesForTarget",
                "organizations:ListRoots",
                "organizations:ListPolicies",
                "organizations:ListTargetsForPolicy"
            ],
            "Resource": "*"
        }
    ]
}
ARP

jenkins_master_policy = <<JMP
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1312295543082",
            "Action": [
                "ec2:DescribeSpotInstanceRequests",
                "ec2:CancelSpotInstanceRequests",
                "ec2:GetConsoleOutput",
                "ec2:RequestSpotInstances",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeRegions",
                "ec2:DescribeImages",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "iam:ListInstanceProfilesForRole",
                "iam:PassRole",
                "ec2:GetPasswordData"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
JMP

##########
## Overall

common_tags = {}
