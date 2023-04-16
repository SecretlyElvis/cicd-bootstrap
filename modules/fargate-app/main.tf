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
      portMappings = var.port_mappings
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

##############
## ECS Service

resource "aws_ecs_service" "service-def" {
  name            = join("-", [ var.basename, "svc" ])
  cluster         = aws_ecs_cluster.cluster-def.id
  task_definition = aws_ecs_task_definition.task-def.arn
  desired_count   = 1
#  iam_role        = var.role_arn
#  depends_on      = [aws_iam_role_policy.foo]

  dynamic "load_balancer" {
    for_each = var.port_tg
    iterator = port
    content {
      target_group_arn = aws_lb_target_group.alb-tg[ port.value ].arn
      container_name   = var.shortname
      container_port   = port.key
    }
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

  count = length(var.app_ports)

  name        = join("-", [ var.basename, "tg", var.subdomains[ count.index ] ])
  port        = var.app_ports[ count.index ]
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled = true 
    interval = 300
    matcher = "200,202"
    path = var.health_check_path
    port = var.app_ports[0]
    protocol = "HTTP"
  }

  tags = merge(
      tomap({
              "Name" = join("-", [ var.basename, "tg", var.subdomains[ count.index ] ])
          }),
      var.common_tags
  )
}


resource "aws_lb_listener" "alb-listener-def" {
  load_balancer_arn = aws_lb.alb-def.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg[0].arn
  }
}

# Add listener rules to forward subdomians to associaed target groups
resource "aws_lb_listener_rule" "static" {

  count = length(var.subdomains)

  listener_arn = aws_lb_listener.alb-listener-def.arn
#  priority     = 100   # allow TF to set automatically

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg[ count.index ].arn
  }

  condition {
    host_header {
      values = [ "${var.subdomains[ count.index ]}.*" ]
    }
  }
}

# add additional 'listener_rule' to route 'docker*' to alternate target group

resource "aws_lb_listener" "redirect-listener" {
  load_balancer_arn = aws_lb.alb-def.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

####################
## Route 53 Elements

data "aws_route53_zone" "target-zone" {
  name         = var.hz_name
  private_zone = false
}

resource "aws_route53_record" "subdomain" {

  count = length(var.subdomains)

  zone_id = data.aws_route53_zone.target-zone.zone_id
  name    = join(".", [ var.subdomains[count.index], var.hz_name ])
  type    = "A"
#  ttl     = "300"

  alias {
    name                   = aws_lb.alb-def.dns_name
    zone_id                = aws_lb.alb-def.zone_id
    evaluate_target_health = false
  }
}
