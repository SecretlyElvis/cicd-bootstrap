# Role to assume for execution of infrastructure actions
role_arn = "arn:aws:iam::339285943866:role/Terraform-Bootstrap"

# Default Region
region = "ap-southeast-2"

# SSM Parameter for Hosted Zone Name
hz_name = "/jenkins/dns/neural-zone-name"

# SSM Parameter for Wildcard Certificate ARN
cert_arn = "/jenkins/cert/neural-wildc-cert-arn"

# Naming Components
application   = "cicd"                     
tenant        = "nrl"                     
environment   = "demo"

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

        # List of IPs to Whitelist for Load Balancer Ingress
        whitelist_ips = []

        docker_image = "sonatype/nexus3:3.55.0"
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

        task_role = true
        task_role_policy = "/iam_policies/Task-DockerExec-Policy.json"
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
