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

stack_defs = [ 
    {
        # JENKINS DEV APP STACK
        app_type = "jenkins"
        name = "jdev"
        cidr = "10.16.3.0/24"

        azs             = ["ap-southeast-2a", "ap-southeast-2b"]
        private_subnets = ["10.16.3.0/27", "10.16.3.32/27"]
        public_subnets  = ["10.16.3.128/27", "10.16.3.160/27"]

        enable_nat_gateway = true
        single_nat_gateway = true
        one_nat_gateway_per_az = false

        access_point = "/efs/jenkins_dev"

        # List of IPs to Whitelist for Load Balancer Ingress
        whitelist_ips = []

        docker_image = "jenkins/jenkins:2.410-jdk11"
        app_ports = [ 8080 ]
        subdomains = [ "jdev" ]
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
            stack_env              = "dev"
            jenkins_master_policy  = "/iam_policies/Jenkins-Master-IAM-Policy.json"
            deployment_role_policy = "/iam_policies/Deployment-Role-Policy.json"
        }
        # List of Role ARNs that can be Assumed by the Jenkins Slave Agent (typically in other accounts)
        assumable_roles        = [ "arn:aws:iam::339285943866:role/TF-Deploy" ]

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
