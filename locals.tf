locals {
  default_common_tags = {

    application           = var.application                     
    tenant                = var.tenant                     
    environment           = var.environment 
    technical_owner       = "andrewn@gentrack.com"             
    business_owner        = "andrewn@gentrack.com"             
    customer_owner        = "andrewn@gentrack.com"

  }
  common_tags = merge(local.default_common_tags, var.common_tags)
  basename = join("-", [ var.tenant, var.application, var.environment ])

  ## Open to All Traffic -- currently used for testing only
  default_security_group_egress = [
    {
      cidr_blocks = "0.0.0.0/0"
      description = "Universal Outbound Traffic"
      from_port = 0
      to_port = 0
      protocol = "-1"
    }
  ]

  ## Open to All Traffic -- currently used for testing only
  default_security_group_ingress = [
    {
      self = true
      cidr_blocks = "0.0.0.0/0"
      description = "Universal Inbound Traffic"
      from_port = 0
      to_port = 0
      protocol = "-1"
    }   
  ]

  # The ip's below are allowed through the firewall to access the Velocity Application
  corporate_ips = [
    "203.167.214.160/32", # Auckland office
    "81.108.106.54/32",  # Gentrack Euston Office
    "31.24.220.131/32",  # Gentrack Tewksbury Office
  ]
  whitelist_ips = concat(local.corporate_ips, var.whitelist_ips)
}

