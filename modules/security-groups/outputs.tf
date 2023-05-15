output "efs_sg_id" {
  description = "The ID of the EFS Security Group"
  value       = try(aws_security_group.efs.id, "")
}

output "ecs_sg_id" {
  description = "The ID of the ECS/Fargate Security Group"
  value       = try(aws_security_group.ecs.id, "")
}

output "alb_sg_id" {
  description = "The ID of the Application Load Balancer Security Group"
  value       = try(aws_security_group.alb.id, "")
}

output "slv_sg_id" {
  description = "The ID of the Jenkins EC2 Slave Agent Security Group"
  value       = try(aws_security_group.slv[0].id, "")
}