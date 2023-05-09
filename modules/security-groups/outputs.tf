output "efs_sg_id" {
  description = "The ID of the EFS instance"
  value       = try(aws_security_group.efs.id, "")
}

#output "file_system_arn" {
#  description = "The ARN of the EFS instance"
#  value       = try(aws_efs_file_system.efs-instance.arn, "")
#}

#output "access_point_id" {
#  description = "The ID of the Access Point"
#  value       = try(aws_efs_access_point.efs-file-path.id, "")
#}

#output "access_point_arn" {
#  description = "The ARN of the Access Point"
#  value       = try(aws_efs_access_point.efs-file-path.arn, "")
#}