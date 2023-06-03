#############################################################################################
## Security Group Definition for Stack
##   - Note: Security Groups are given specific names to be referenced in subsequent modules

#################################
## ALB: Application Load Balancer

resource "aws_security_group" "alb" {
  name        = join("-", [ var.basename, "${var.shortname}_ALB", "sg" ])
  description = "ECS/Fargate Security Group - ${var.shortname}"
  vpc_id      = var.vpc_id

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "${var.shortname}_ALB", "sg" ])
          }),
      var.common_tags
  )
}

# ALB Ingress: 443 from NAT Gateway EIP(s)
resource "aws_vpc_security_group_ingress_rule" "alb-ingress-nat" {
  
  count = length(var.nat_ips)

  security_group_id = aws_security_group.alb.id
  cidr_ipv4   = "${var.nat_ips[count.index]}/32"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  depends_on = [aws_security_group.alb]
}

# ALB Ingress: 443 from Whitelist IPs
resource "aws_vpc_security_group_ingress_rule" "alb-ingress-https" {
  
  count = length(var.whitelist_ips)

  security_group_id = aws_security_group.alb.id
  cidr_ipv4   = var.whitelist_ips[count.index]
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  depends_on = [aws_security_group.alb]
}

# ALB Egress - App Ports to ECS
resource "aws_vpc_security_group_egress_rule" "alb-egress-app" {

  count = length(var.app_ports)
  
  security_group_id = aws_security_group.alb.id

  # cidr_ipv4   = var.vpc_cidr
  from_port   = var.app_ports[count.index]
  ip_protocol = "tcp"
  to_port     = var.app_ports[count.index]
  depends_on = [aws_security_group.alb]
  referenced_security_group_id = aws_security_group.ecs.id
}

##################################################
## EFS: Elastic File System Backend Security Group

resource "aws_security_group" "efs" {
  name        = join("-", [ var.basename, "${var.shortname}_EFS", "sg" ])
  description = "EFS Security Group - ${var.shortname}"
  vpc_id      = var.vpc_id

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "${var.shortname}_EFS", "sg" ])
          }),
      var.common_tags
  )
}

# EFS Ingress - NFS from ECS SG
resource "aws_vpc_security_group_ingress_rule" "efs-ingress-nfs" {
  
  security_group_id = aws_security_group.efs.id
  # cidr_ipv4   = var.vpc_cidr
  from_port   = 2049
  ip_protocol = "tcp"
  to_port     = 2049
  depends_on = [aws_security_group.efs]
  referenced_security_group_id = aws_security_group.ecs.id
}

# EFS Egress - NFS Protocols to ECS SG
resource "aws_vpc_security_group_egress_rule" "efs-egress-nfs" {

  security_group_id = aws_security_group.efs.id
  # cidr_ipv4   = var.vpc_cidr
  from_port   = "2049"
  ip_protocol = "tcp"
  to_port     = "2049"
  depends_on = [aws_security_group.efs]
  referenced_security_group_id = aws_security_group.ecs.id
}

#######################################
## ECS Service / Fargate Security Group

resource "aws_security_group" "ecs" {
  name        = join("-", [ var.basename, "${var.shortname}_ECS", "sg" ])
  description = "ECS/Fargate Security Group - ${var.shortname}"
  vpc_id      = var.vpc_id

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "${var.shortname}_ECS", "sg" ])
          }),
      var.common_tags
  )
}

# ECS Ingress - App Ports from LB
resource "aws_vpc_security_group_ingress_rule" "ecs-ingress-app" {

  count = length(var.app_ports)
  
  security_group_id = aws_security_group.ecs.id

  # cidr_ipv4   = var.vpc_cidr
  from_port   = var.app_ports[count.index]
  ip_protocol = "tcp"
  to_port     = var.app_ports[count.index]
  depends_on = [aws_security_group.ecs]
  referenced_security_group_id = aws_security_group.alb.id
}

# ECS Ingress - NFS from EFS SG
resource "aws_vpc_security_group_ingress_rule" "ecs-ingress-nfs" {

  security_group_id = aws_security_group.ecs.id
  # cidr_ipv4   = local.global_cidr
  from_port   = 2049
  ip_protocol = "tcp"
  to_port     = 2049
  depends_on = [aws_security_group.ecs]
  referenced_security_group_id = aws_security_group.efs.id
}

# ECS Egress - HTTPS to 'world' (Access to Module Services, etc. -- will be NAT-ted)
resource "aws_vpc_security_group_egress_rule" "ecs-egress-https" {

  security_group_id = aws_security_group.ecs.id
  cidr_ipv4   = local.global_cidr
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  depends_on = [aws_security_group.ecs]
}

# ECS Egress - SSH to 'world' (Used by Git -- will be NAT-ted)
resource "aws_vpc_security_group_egress_rule" "ecs-egress-ssh" {

  security_group_id = aws_security_group.ecs.id
  cidr_ipv4   = local.global_cidr
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22  
  depends_on = [aws_security_group.ecs]
}

# ECS Egress - NFS to EFS SG
resource "aws_vpc_security_group_egress_rule" "ecs-egress-nfs" {

  security_group_id = aws_security_group.ecs.id
  # cidr_ipv4   = local.global_cidr
  from_port   = 2049
  ip_protocol = "tcp"
  to_port     = 2049
  depends_on = [aws_security_group.ecs]
  referenced_security_group_id = aws_security_group.efs.id
}

# ECS Egress - ALL Protocols to SLV SG (Jenkins only)
resource "aws_vpc_security_group_egress_rule" "ecs-egress-slv" {

  count = (var.app_type == "jenkins") ? 1 : 0

  security_group_id = aws_security_group.ecs.id
  # cidr_ipv4   = var.vpc_cidr
  # from_port   = ""
  ip_protocol = "all"
  # to_port     = ""
  depends_on = [aws_security_group.ecs]
  referenced_security_group_id = aws_security_group.slv[0].id
}


#########################################
## SLV: Jenkins EC2 Slave Agent (Jenkins only)

resource "aws_security_group" "slv" {

  count = (var.app_type == "jenkins") ? 1 : 0

  name        = join("-", [ var.basename, "${var.shortname}_SLV", "sg" ])
  description = "EC2 Jenkins Slave Security Group - ${var.shortname}"
  vpc_id      = var.vpc_id

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "${var.shortname}_SLV", "sg" ])
          }),
      var.common_tags
  )
}

# SLV Ingress: ALL from ECS (Jenkins Master)
resource "aws_vpc_security_group_ingress_rule" "slv-ingress-ecs" {

  count = (var.app_type == "jenkins") ? 1 : 0

  security_group_id = aws_security_group.slv[count.index].id
  # cidr_ipv4   = var.vpc_cidr
  # from_port   = ""
  ip_protocol = "all"
  # to_port     = ""
  depends_on = [aws_security_group.slv]
  referenced_security_group_id = aws_security_group.ecs.id  
}

# SLV Egress: HTTPS to 'world' (Docker, etc. -- will be NAT-ted)
resource "aws_vpc_security_group_egress_rule" "slv-egress-https" {

  count = (var.app_type == "jenkins") ? 1 : 0

  security_group_id = aws_security_group.slv[count.index].id
  cidr_ipv4   = local.global_cidr
  from_port   = "443"
  ip_protocol = "tcp"
  to_port     = "443"
  depends_on = [aws_security_group.slv]  
}

# SLV Egress: SSH to 'world' (Git, etc. -- will be NAT-ted)
resource "aws_vpc_security_group_egress_rule" "slv-egress-ssh" {

  count = (var.app_type == "jenkins") ? 1 : 0

  security_group_id = aws_security_group.slv[count.index].id
  cidr_ipv4   = local.global_cidr
  from_port   = "22"
  ip_protocol = "tcp"
  to_port     = "22"
  depends_on = [aws_security_group.slv]  
}

# SLV Egress: 80 to Metadata Service (for Instance Profile)
resource "aws_vpc_security_group_egress_rule" "slv-egress-mets" {

  count = (var.app_type == "jenkins") ? 1 : 0

  security_group_id = aws_security_group.slv[count.index].id
  cidr_ipv4   = local.meta_cidr
  from_port   = "80"
  ip_protocol = "tcp"
  to_port     = "80"
  depends_on = [aws_security_group.slv]  
}

# SLV Egress: ALL to ECS (Jenkins Master)
resource "aws_vpc_security_group_egress_rule" "slv-egress-ecs" {

  count = (var.app_type == "jenkins") ? 1 : 0

  security_group_id = aws_security_group.slv[count.index].id
  # cidr_ipv4   = var.vpc_cidr
  # from_port   = ""
  ip_protocol = "all"
  # to_port     = ""
  depends_on = [aws_security_group.slv]
  referenced_security_group_id = aws_security_group.ecs.id  
}

# Security Group:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

# Ingress Rule:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule#to_port

# Egress Rule:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule






