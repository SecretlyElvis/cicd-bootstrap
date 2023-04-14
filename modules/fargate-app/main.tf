##############
## ECS Cluster

resource "aws_ecs_cluster" "cluster-def" {
  name = join("-", [ var.basename, "ecs" ])

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "ecs" ])
          }),
      var.common_tags
  ) 
}

resource "aws_ecs_cluster_capacity_providers" "cap-prv-def" {
  cluster_name = aws_ecs_cluster.cluster-def.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

#######################################
## Fargate Task Definition (with mount)

resource "aws_ecs_task_definition" "task-def" {
  family                   = var.shortname
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2 vCPU"
  memory                   = 4096
 
  container_definitions    = jsonencode([
    {
      name      = "${var.shortname}"
      image     = "${var.docker_image}"
      cpu       = 2048
      memory    = 4096
      essential = true
      portMappings = [
        {
          containerPort = tonumber(var.app_port)
          hostPort      = tonumber(var.app_port)
        }
      ]
      mountPoints = [
        {
          sourceVolume = "${var.shortname}-storage"
          containerPath = "${var.container_mount}"
          readOnly = false 
        }
      ]
    }
  ])

  volume {
    name = join("-", [ var.shortname, "storage" ])

    efs_volume_configuration {
      file_system_id          = var.file_system_id
      transit_encryption      = "ENABLED"

      authorization_config {
        access_point_id = var.access_point_id
        iam             = "DISABLED"
      }
    }
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "task" ])
          }),
      var.common_tags
  )
}

################################################
## Security Groups for Application Load Balancer

# TODO

#################
## ALB Components

resource "aws_lb" "alb-def" {
  name               = join("-", [ var.basename, "alb" ])
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.default_security_group_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

#  access_logs {
#    bucket  = aws_s3_bucket.lb_logs.id
#    prefix  = "test-lb"
#    enabled = true
#  }

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "alb" ])
          }),
      var.common_tags
  )
}

resource "aws_lb_target_group" "alb-tg" {
  name        = join("-", [ var.basename, "tg" ])
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled = true 
    interval = 300
    matcher = "200,202"
    path = var.health_check_path
    port = var.app_port
    protocol = "HTTP"
  }

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "tg" ])
          }),
      var.common_tags
  )
}

resource "aws_lb_listener" "alb-listener-def" {
  load_balancer_arn = aws_lb.alb-def.arn
  port              = "80"
  protocol          = "HTTP"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

##############
## ECS Service

resource "aws_ecs_service" "service-def" {
  name            = join("-", [ var.basename, "svc" ])
  cluster         = aws_ecs_cluster.cluster-def.id
  task_definition = aws_ecs_task_definition.task-def.arn
  desired_count   = 1
#  iam_role        = aws_iam_role.foo.arn
#  depends_on      = [aws_iam_role_policy.foo]

  load_balancer {
    target_group_arn = aws_lb_target_group.alb-tg.arn
    container_name   = var.shortname
    container_port   = var.app_port
  }

  network_configuration {
    subnets            = var.public_subnets
    security_groups    = [var.default_security_group_id]
    assign_public_ip = true
  }

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "svc" ])
          }),
      var.common_tags
  )
}
