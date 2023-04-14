##############
## Create VPCs

module "vpc-standup" {

  source = "./modules/core-networking"

  count = length(var.vpc_defs)

  name = join("-", [ local.basename, var.vpc_defs[count.index].name ])
  cidr = var.vpc_defs[count.index].cidr 

  azs             = var.vpc_defs[count.index].azs
  private_subnets = var.vpc_defs[count.index].private_subnets
  public_subnets  = var.vpc_defs[count.index].public_subnets

  enable_dns_hostnames = true
  enable_dns_support = true

  enable_nat_gateway = var.vpc_defs[count.index].enable_nat_gateway
  single_nat_gateway = var.vpc_defs[count.index].single_nat_gateway
  one_nat_gateway_per_az = var.vpc_defs[count.index].one_nat_gateway_per_az

  manage_default_security_group = true
  default_security_group_name = join("-", [ local.basename, var.vpc_defs[count.index].name ])
  default_security_group_egress = local.default_security_group_egress
  default_security_group_ingress = local.default_security_group_ingress

  tags = local.common_tags

}

#################################
## Create VPC Peering Connections

module "vpc-peers" {

  source = "./modules/vpc-peer-and-route"

  for_each = var.peering_pairs

  jenkins_vpc_id = module.vpc-standup[each.value[0]].vpc_id
  jenkins_vpc_cidr = var.vpc_defs[each.value[0]].cidr 
  jenkins_route_table_id = module.vpc-standup[each.value[0]].default_route_table_id
  jenkins_public_rt = module.vpc-standup[each.value[0]].public_route_table_ids
  jenkins_private_rt = module.vpc-standup[each.value[0]].private_route_table_ids

  nexus_vpc_id = module.vpc-standup[each.value[1]].vpc_id
  nexus_vpc_cidr = var.vpc_defs[each.value[1]].cidr
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

  count = length(var.vpc_defs)

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

##########################################################
## Create EFS Instance with Mount Targets and Access Point

module "efs-standup" {

  source = "./modules/efs-elements"
  
  count = length(var.vpc_defs) 

  access_point = var.vpc_defs[count.index].access_point
  public_subnets = module.vpc-standup[count.index].public_subnets

  common_tags = local.common_tags
  basename = join("-", [ local.basename, var.vpc_defs[count.index].name ])

}

#####################################################################
##  Deploy App,lications Into Fargate with ALB and EFS-Backed Storage

module "app-standup" {

  source = "./modules/fargate-app"
  
  count = length(var.vpc_defs)

  docker_image = var.vpc_defs[count.index].docker_image
  app_port = var.vpc_defs[count.index].app_port
  container_mount = var.vpc_defs[count.index].container_mount
  health_check_path = var.vpc_defs[count.index].health_check_path

  file_system_id = module.efs-standup[count.index].file_system_id
  access_point_id = module.efs-standup[count.index].access_point_id

  default_security_group_id = module.vpc-standup[count.index].default_security_group_id
  public_subnets = module.vpc-standup[count.index].public_subnets
  vpc_id      = module.vpc-standup[count.index].vpc_id

  common_tags = local.common_tags
  basename = join("-", [ local.basename, var.vpc_defs[count.index].name ])
  shortname = var.vpc_defs[count.index].name

}