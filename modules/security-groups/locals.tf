locals {
  global_cidr = "0.0.0.0/9"

  efs_ingress = [ 2049, 22 ]
  efs_egress = [ 0 ]

  fargate_ingress = [ 22, 2049 ] # VPC CIDR

  fargate_egress = [ 443 ] # to 0.0.0.0/0 (will be NAT-ed)
  fargate_egress_intra = [ 22, 50000, 2049 ] # ICMP VPC CIDR 

  jenkins_slave_ingress = [ 22, 50000, "ICMP" ] # from 'fargate' SG 
}

# ======= NOTES ========

# Fargate:
# egress: 2049 to VPC, ICMP to VPC, 8080 to VPC, 50000 to VPC (JNLP4), 22 to VPC (slave connection), 443 to 0.0.0.0/0, 80 to 0.0.0/0 (for capturing modules, etc.) -- NAT gateway
# ingress: 8080 from LB SG, 2049 from VPC CIDR  

# Slave:
# egress: 22 to 0.0.0.0/0 (for git) - NAT Gateway, 50000 to VPC (JNLP), 443 egress to VPC (docker) 
# ingress:  50000 frm SG, 22 from SG

# LB:
# egress:
# ingress:

## NEXUS ## Security Groups by Area:

# EFS:
# egress: 2049 to VPC 
# ingress: 2049 from Fargate security group 


# Fargate:
# egress: 
# ingress:  8081 from LB SG, 8082 from LB SG

# LB:
# egress:
# ingress: