# Role to assume for execution of infrastructure actions
role_arn = "arn:aws:iam::405711654092:role/OrganizationAccountAccessRole"

# Default Region
region = "ap-southeast-2"

# SSM Parameter for Hosted Zone Name
hz_name = "/jenkins/dns/prd-zone-name"

# SSM Parameter for Wildcard Certificate ARN
cert_arn = "/jenkins/cert/production-wildc-cert-arn"

# Naming Components
application   = "cicd"                     
tenant        = "peo"                     
environment   = "prd"

# List of IPs to Whitelist for Load Balancer Ingress
whitelist_ips = [
    "101.98.162.108/32", # TEMP: Dan's Home Office
    "125.239.144.52/32", # TEMP: Andrew's Home Office
]

###################################
## Stack Configuration: Jenkins DEV

stack_defs = [ 
    {
        # JENKINS PRD APP STACK
        app_type = "jenkins"
        name = "jprd"
        cidr = "10.16.5.0/24"

        azs             = ["ap-southeast-2a", "ap-southeast-2c"]
        private_subnets = ["10.16.5.0/27", "10.16.5.32/27"]
        public_subnets  = ["10.16.5.128/27", "10.16.5.160/27"]

        enable_nat_gateway = true
        single_nat_gateway = true
        one_nat_gateway_per_az = false

        access_point = "/efs/jenkins_dev"

        docker_image = "jenkins/jenkins:2.405-jdk11"
        app_ports = [ 8080 ]
        subdomains = [ "prod" ]
        health_check_path = "/login"
        container_mount = "/var/jenkins_home"
        port_mappings = [
            {
            containerPort = 8080
            hostPort      = 8080
            },
            {
            containerPort = 50000
            hostPort      = 50000
            }            
        ]
        port_tg = {
            8080 = 0
        }

        # IAM Components
        create_iam    = true
        iam_components = {
            stack_env              = "prd"
            jenkins_master_policy  = "/JPRD/Jenkins-Master-IAM-Policy.json"
            deployment_role_policy = "/JPRD/Deployment-Role-Policy.json"
        }
        # List of Role ARNs that can be Assumed by the Jenkins Slave Agent (typically in other accounts)
        assumable_roles        = [ "arn:aws:iam::667873832206:role/OrganizationAccountAccessRole" ]
    },  
]

#######################################################################
## VPC Peering Connections (Jenkins DEV -> Nexus, Jenkins PRD -> Nexus)
## Refs to index values in 'stack_defs' array

peering_pairs = {

#    jdev_to_nexus = [0, 1]
#    jprd_to_nexus = [2, 1]

}    

##########
## Overall

common_tags = {}
