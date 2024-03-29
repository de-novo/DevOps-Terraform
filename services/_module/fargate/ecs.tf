
## ECS IAM
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"

  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.service_name}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.service_name}-ecs-tasks"
  description = "Allow inbound traffic from ALB"
  vpc_id      = var.target_vpc

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


## ECS Cluster
data "template_file" "service" {
  template = file(var.tpl_path)
  vars = {
    app_name           = var.service_name
    aws_ecr_repository = var.aws_ecr_repository
    tag                = "latest"
    cpu                = var.cpu
    memory             = var.memory
    container_port     = var.container_port
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.service_name}-task"
  container_definitions    = data.template_file.service.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu    // default 256
  memory                   = var.memory // default 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

}



resource "aws_ecs_cluster" "cluster" {
  name = "${var.service_name}-cluster"
}

resource "aws_ecs_service" "service" {
  name                 = "${var.service_name}-service"
  cluster              = aws_ecs_cluster.cluster.id
  task_definition      = aws_ecs_task_definition.service.arn
  desired_count        = var.desired_count
  force_new_deployment = true
  launch_type          = "FARGATE"


  network_configuration {
    subnets         = var.private_subnets
    security_groups = concat(var.security_groups, [aws_security_group.ecs_tasks.id])
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role,
    aws_iam_role_policy_attachment.ecr_read_only
  ]

  tags = {
    Name        = "${var.service_name}-service"
    Application = var.service_name
  }

}

