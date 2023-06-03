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
    "54.206.253.253/32", # Jenkins DEV NAT Gateway EIP
    "101.98.162.108/32", # TEMP: Dan's Home Office
]

###################################
## Stack Configuration: Jenkins DEV

stack_defs = [ 
     {
        # NEXUS APP STACK
        app_type = "nexus"
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

        # IAM Components
        create_iam      = false
        iam_components  = {}
        assumable_roles = []   
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
