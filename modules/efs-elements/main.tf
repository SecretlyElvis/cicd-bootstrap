###################################
## Create EFS File System (all AZs)

resource "aws_efs_file_system" "efs-instance" {
  creation_token = var.basename

  performance_mode = "generalPurpose"
  throughput_mode = "bursting"

#  lifecycle_policy {
#    transition_to_ia = "AFTER_30_DAYS"
#  }

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "efs" ])
          }),
      var.common_tags
  ) 
}

## Create the file path that will be used by Jenkins DEV/PRD and Nexus
resource "aws_efs_access_point" "efs-file-path" {
    file_system_id = aws_efs_file_system.efs-instance.id
    
    root_directory {
        path = var.access_point

        creation_info {
            owner_gid  = "0"
            owner_uid  = "11"
            permissions = "777"
        } 
    }

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "ap" ])
          }),
      var.common_tags
  ) 

}

## Create Mount Targets for Each Subnet in the VPC
resource "aws_efs_mount_target" "mt" {
 
    count = length(var.public_subnets)
 
    file_system_id = aws_efs_file_system.efs-instance.id
    subnet_id      = var.public_subnets[count.index]
 
    # security_groups = TODO
}