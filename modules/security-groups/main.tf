######################################
## Security Group Definition for Stack
##   - Note: Security Groups are given specific names to be referenced in subsequent modules

## EFS

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

# EFS Ingress
resource "aws_vpc_security_group_ingress_rule" "efs-ingress" {

  count = length(local.efs_ingress)
  
  security_group_id = aws_security_group.efs.id

  cidr_ipv4   = var.vpc_cidr
  from_port   = local.efs_ingress[count.index]
  ip_protocol = "tcp"
  to_port     = local.efs_ingress[count.index]
  # referenced_security_group_id 
}

# EFS Egress
resource "aws_vpc_security_group_egress_rule" "efs-egress" {

  count = length(local.efs_egress)

  security_group_id = aws_security_group.efs.id

  cidr_ipv4   = var.vpc_cidr
  from_port   = local.efs_egress[count.index]
  ip_protocol = "-1"
  to_port     = local.efs_egress[count.index]
  # referenced_security_group_id 
}


## Note for EC2 Slaves: open egress port to metadata port 80: 169.254.169.254


#Security Group:
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

# Egress Rule:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule

# Ingress Rule:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule#to_port

## JENKINS ## Security Groups by Area:





