variable "ecs"{
  type = object({
    hostPort = string
    containerPort = string
    vpc_id = string
    project = string
    healthCheck_path = string
    cluster_arn = string
    service_desidedCount = number
    memoryReservation = number
    image = string
    imageVersion = string
    execution_role_arn = string
    alb_arn = string
    containerVolumePath = string
  })
  default = {
      hostPort ="1"
      containerPort = "1"
      project = ""
      healthCheck_path = ""
      service_desidedCount = 1
      memoryReservation = 100
      image = ""
      vpc_id = "vpc-013f23be651430cb0"
      cluster_arn = "arn:aws:ecs:us-east-1:152835622754:cluster/terraTuto"
      imageVersion = "latest"
      execution_role_arn       = "arn:aws:iam::152835622754:role/ecsTaskExecutionRole"
      alb_arn = "arn:aws:elasticloadbalancing:us-east-1:152835622754:loadbalancer/app/terraTuto-terraTuto/b8ae32e752322e67"
      containerVolumePath = ""
  }
  description = "The values of each ECS service and task"
}
variable "region"{
  type = string
  default = "us-east-1"
}