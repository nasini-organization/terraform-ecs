resource "aws_ecs_service" "nginx" {
  name            = "${var.task_name}"                              # Naming our first service
  cluster         = var.cluster_arn                # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.nginx.arn # Referencing the task our service will spin up
  launch_type     = "EC2"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_alb_target_group.senebi_back.arn
    container_name   = aws_ecs_task_definition.senebi_back.family
    container_port   = "80" # Specifying the container port
  }
}

##
resource "aws_alb_target_group" "senebi_back" {
  name                 = "${var.project}-sen${substr(uuid(), 0, 1)}"
  port                 = 8002
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
#  deregistration_delay = var.deregistration_delay

  health_check {
    path     = "/docs"
    protocol = "HTTP"
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}
resource "aws_alb_listener" "senebi_back" {
  load_balancer_arn = var.alb_arn
  port              = "8002"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.senebi_back.id
    type             = "forward"
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.task_name}" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.task_name}",
      "image": "jc21/nginx-proxy-manager:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        },
        {
          "containerPort": 81,
          "hostPort": 81
        },
        {
          "containerPort": 443,
          "hostPort": 443
        }
      ],
      "memoryReservation": 100
    }
  ]
  DEFINITION
  requires_compatibilities = ["EC2"]     # Stating that we are using ECS Fargate
  network_mode             = "bridge"        # Using awsvpc as our network mode as this is required for Fargate
  #memory                   = var.task-memory # Specifying the memory our container requires
  # cpu                      = var.task-cpu    # Specifying the CPU our container requires
  # execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  execution_role_arn       = "arn:aws:iam::152835622754:role/ecsTaskExecutionRole"
}
