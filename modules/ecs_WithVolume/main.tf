resource "aws_alb_target_group" "tg" {
  name                 = "${var.ecs.project}-${substr(uuid(), 0, 1)}"  
  port                 = 80 //host port
  protocol             = "HTTP"
  vpc_id               = var.ecs.vpc_id
#  deregistration_delay = var.deregistration_delay

  health_check {
    path     = var.ecs.healthCheck_path
    protocol = "HTTP"
    port = 81
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}
resource "aws_alb_target_group" "tg2" {
  name                 = "${var.ecs.project}-${substr(uuid(), 0, 1)}"  
  port                 = 81 //host port
  protocol             = "HTTP"
  vpc_id               = var.ecs.vpc_id
#  deregistration_delay = var.deregistration_delay

  health_check {
    path     = var.ecs.healthCheck_path
    protocol = "HTTP"
    port = 81
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}
resource "aws_alb_target_group" "tg3" {
  name                 = "${var.ecs.project}-${substr(uuid(), 0, 1)}"  
  port                 = 443 //host port
  protocol             = "HTTP"
  vpc_id               = var.ecs.vpc_id
#  deregistration_delay = var.deregistration_delay

  health_check {
    path     = var.ecs.healthCheck_path
    protocol = "HTTP"
    port = 81
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}
resource "aws_alb_listener" "listener" {
  load_balancer_arn = var.ecs.alb_arn
  port              = 80 //host port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg.id
    type             = "forward"
  }
}
resource "aws_alb_listener" "listener2" {
  load_balancer_arn = var.ecs.alb_arn
  port              = 81 //host port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg2.id
    type             = "forward"
  }
}
resource "aws_alb_listener" "listener3" {
  load_balancer_arn = var.ecs.alb_arn
  port              = 443 //host port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg3.id
    type             = "forward"
  }
}
resource "aws_ecs_service" "service" {
  name            = "${var.ecs.project}"                              # Naming our first service
  cluster         = var.ecs.cluster_arn                # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.task.arn # Referencing the task our service will spin up
  launch_type     = "EC2"
  desired_count   = var.ecs.service_desidedCount
  placement_constraints{
    type       = "memberOf"
    expression = "attribute:service==nginx"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.tg.arn
    container_name   = aws_ecs_task_definition.task.family
    container_port   = 80 # Specifying the container port
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.tg2.arn
    container_name   = aws_ecs_task_definition.task.family
    container_port   = 81 # Specifying the container port
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.tg3.arn
    container_name   = aws_ecs_task_definition.task.family
    container_port   = 443 # Specifying the container port
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.ecs.project}"  # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.ecs.project}",
      "image": "${var.ecs.image}:${var.ecs.imageVersion}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        },
        {
          "containerPort": 443,
          "hostPort": 443
        },
        {
          "containerPort": 81,
          "hostPort": 81
        }
      ],
      "memoryReservation": ${var.ecs.memoryReservation},
      "logConfiguration": {
         "logDriver": "awslogs",
         "options": {
             "awslogs-group": "${var.ecs.project}",
             "awslogs-region": "${var.region}",
             "awslogs-stream-prefix": "awslogs-"
         }
       },
       "mountPoints": [
         {
           "sourceVolume": "${var.ecs.project}-vol",
           "containerPath": "${var.ecs.containerVolumePath}"
         },
         {
           "sourceVolume": "${var.ecs.project}-vol",
           "containerPath": "/etc/letsencrypt"
         }
       ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["EC2"]     # Stating that we are using ECS Fargate
  network_mode             = "bridge"        # Using awsvpc as our network mode as this is required for Fargate
  execution_role_arn       = var.ecs.execution_role_arn
  volume {
    name = "${var.ecs.project}-vol"
    docker_volume_configuration {
      scope = "shared"
      autoprovision = true
      driver        = "local"
    }
  }
}
resource "aws_cloudwatch_log_group" "task" {
  name = "${var.ecs.project}"
  retention_in_days = 7
}