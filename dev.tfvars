# A name to describe the environment we're creating.
environment = "terraTuto"

# The AWS-CLI profile for the account to create resources in.
aws_profile = "luciano.buono-nasini"

# The AWS region to create resources in.
aws_region           = "us-east-1"

# The AMI to seed ECS instances with.
# Leave empty to use the latest Linux 2 ECS-optimized AMI by Amazon.
aws_ecs_ami = ""

# The IP range to attribute to the virtual network.
# The allowed block size is between a /16 (65,536 addresses) and /28 (16 addresses).
vpc_cidr = "10.0.0.0/16"

# The IP ranges to use for the public subnets in your VPC.
# Must be within the IP range of your VPC.
public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]

# The IP ranges to use for the private subnets in your VPC.
# Must be within the IP range of your VPC.
private_subnet_cidrs = ["10.0.50.0/24", "10.0.51.0/24"]

# The AWS availability zones to create subnets in.
# For high-availability, we need at least two.
availability_zones = ["us-east-1a", "us-east-1b"]

# Maximum number of instances in the ECS cluster.
max_size = 4

# Minimum number of instances in the ECS cluster.
min_size = 1

# Ideal number of instances in the ECS cluster.
desired_capacity = 2

# Size of instances in the ECS cluster.
instance_type = "t2.micro"



ecs = [
  //NGINX
  {
    hostPort = "80"
    containerPort = "80"
    project = "nginx"
    healthCheck_path = "/"
    service_desidedCount = 1
    memoryReservation = 110
    image = "jc21/nginx-proxy-manager"
    imageVersion = "latest"
    containerVolumePath = "/data"

    vpc_id = "vpc-013f23be651430cb0"
    cluster_arn = "arn:aws:ecs:us-east-1:152835622754:cluster/terraTuto"
    imageVersion = "latest"
    execution_role_arn       = "arn:aws:iam::152835622754:role/ecsTaskExecutionRole"
    alb_arn = "arn:aws:elasticloadbalancing:us-east-1:152835622754:loadbalancer/app/terraTuto-terraTuto/b8ae32e752322e67"
  }
]