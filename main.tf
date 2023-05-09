##############
## Create VPCs

module "vpc-standup" {

  source = "./modules/core-networking"

  count = length(var.stack_defs)

  name = join("-", [ local.basename, var.stack_defs[count.index].name ])
  cidr = var.stack_defs[count.index].cidr 

  azs             = var.stack_defs[count.index].azs
  private_subnets = var.stack_defs[count.index].private_subnets
  public_subnets  = var.stack_defs[count.index].public_subnets

  enable_dns_hostnames = true
  enable_dns_support = true

  enable_nat_gateway = var.stack_defs[count.index].enable_nat_gateway
  single_nat_gateway = var.stack_defs[count.index].single_nat_gateway
  one_nat_gateway_per_az = var.stack_defs[count.index].one_nat_gateway_per_az

  manage_default_security_group = true
  default_security_group_name = join("-", [ local.basename, var.stack_defs[count.index].name ])
  default_security_group_egress = local.default_security_group_egress
  default_security_group_ingress = local.default_security_group_ingress

  tags = local.common_tags

}

#########################################################
## Create VPC Peering Connections (if defined in .tfvars)

module "vpc-peers" {

  source = "./modules/vpc-peer-and-route"

  for_each = var.peering_pairs

  jenkins_vpc_id = module.vpc-standup[each.value[0]].vpc_id
  jenkins_vpc_cidr = var.stack_defs[each.value[0]].cidr 
  jenkins_route_table_id = module.vpc-standup[each.value[0]].default_route_table_id
  jenkins_public_rt = module.vpc-standup[each.value[0]].public_route_table_ids
  jenkins_private_rt = module.vpc-standup[each.value[0]].private_route_table_ids

  nexus_vpc_id = module.vpc-standup[each.value[1]].vpc_id
  nexus_vpc_cidr = var.stack_defs[each.value[1]].cidr
  nexus_route_table_id = module.vpc-standup[each.value[1]].default_route_table_id
  nexus_public_rt = module.vpc-standup[each.value[1]].public_route_table_ids
  nexus_private_rt = module.vpc-standup[each.value[1]].private_route_table_ids

  common_tags = local.common_tags
  name_prefix = join("-", [ local.basename, each.key ]) 

}

####################################
# VPC Endpoints (Currently only SSM)

module "vpc-endpoints" {

  source = "./modules/core-networking/modules/vpc-endpoints"

  count = length(var.stack_defs)

  vpc_id             = module.vpc-standup[count.index].vpc_id
  security_group_ids = [ module.vpc-standup[count.index].default_security_group_id ]

  endpoints = {
      ssm = {
        service             = "ssm"
        private_dns_enabled = false
        subnet_ids          = module.vpc-standup[count.index].public_subnets
      }
  }

  tags = merge(
      tomap({
              "Name" = join("-", [ local.basename, module.vpc-standup[count.index].name, "ep" ])
          }),
      var.common_tags
  ) 
}

##################
## Security Groups

module "sg-defs" {

  source = "./modules/security-groups"

  count = length(var.stack_defs)

  vpc_id = module.vpc-standup[count.index].vpc_id
  vpc_cidr = var.stack_defs[count.index].cidr 
  app_ports = var.stack_defs[count.index].app_ports

  app_type = var.stack_defs[count.index].app_type
  shortname = var.stack_defs[count.index].name
  basename = join("-", [ local.basename, var.stack_defs[count.index].name ])

  common_tags = local.common_tags
}

##########################################################
## Create EFS Instance with Mount Targets and Access Point

module "efs-standup" {

  source = "./modules/efs-elements"
  
  count = length(var.stack_defs) 

  access_point = var.stack_defs[count.index].access_point
  private_subnets = module.vpc-standup[count.index].private_subnets
  efs_sg_id = module.sg-defs[count.index].efs_sg_id

  common_tags = local.common_tags
  basename = join("-", [ local.basename, var.stack_defs[count.index].name ])

}

#####################################################################
##  Deploy App,lications Into Fargate with ALB and EFS-Backed Storage

module "app-standup" {

  source = "./modules/fargate-app"
  
  count = length(var.stack_defs)

  # ECS
  docker_image = var.stack_defs[count.index].docker_image
  app_ports = var.stack_defs[count.index].app_ports
  container_mount = var.stack_defs[count.index].container_mount
  port_mappings = var.stack_defs[count.index].port_mappings
  port_tg = var.stack_defs[count.index].port_tg
  health_check_path = var.stack_defs[count.index].health_check_path
  private_subnets = module.vpc-standup[count.index].private_subnets

  # EFS
  file_system_id = module.efs-standup[count.index].file_system_id
  access_point_id = module.efs-standup[count.index].access_point_id

  # ALB
  default_security_group_id = module.vpc-standup[count.index].default_security_group_id
  public_subnets = module.vpc-standup[count.index].public_subnets
  vpc_id = module.vpc-standup[count.index].vpc_id

  # Route 53
  hz_name = var.hz_name
  cert_arn = var.cert_arn
  subdomains = var.stack_defs[count.index].subdomains

  common_tags = local.common_tags
  basename = join("-", [ local.basename, var.stack_defs[count.index].name ])
  shortname = var.stack_defs[count.index].name

}

#######################################################################################
## Create IAM Elements for Jenkins (Instance Profile, IAM User for Slave Agent Standup)
## Note; TF doesn't suppert 'if-then-else' so this is the poor man's version

module "iam-standup" {

  source = "./modules/iam-elements"
  
  count = var.create_iam ? 1 : 0

  assumable_roles = var.assumable_roles
  deployment_role_policy = var.deployment_role_policy
  jenkins_master_policy = var.jenkins_master_policy
  
  common_tags = local.common_tags
  basename = local.basename

}