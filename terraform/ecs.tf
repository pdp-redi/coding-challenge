# ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "${var.env}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS Task definition
resource "aws_ecs_task_definition" "my_task" {
  family                   = var.ecs_task_defination
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  #task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name   = var.ecr_container
      image  = "816069142677.dkr.ecr.ap-south-1.amazonaws.com/my-ecr-repo"
      cpu    = tonumber(var.fargate_cpu)
      memory = tonumber(var.fargate_memory)
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
        }
      ]
    }
  ])
}

# ECS service
resource "aws_ecs_service" "my_service" {
  name            = "${var.env}-ecs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets = aws_subnet.private_subnets[*].id # Replace with your subnet IDs
    #assign_public_ip = true
    assign_public_ip = false                               # Set to false for private subnets
    security_groups  = [aws_security_group.ecs_task_sg.id] # We'll define this security group
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.id
    container_port   = var.container_port
    container_name   = var.ecr_container
  }

  depends_on = [
    aws_ecr_repository.ecr_repo,
    aws_ecs_task_definition.my_task,
    aws_vpc.vpc,
    aws_lb_listener.alb_listener
  ]
}
