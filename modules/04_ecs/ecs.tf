resource "aws_ecs_cluster" "hello_world" {
    name = "hello-world"

    configuration {
    execute_command_configuration {
        logging = "DEFAULT"
      }
  }
}

resource "aws_ecs_service" "hello_world" {
    cluster                            = aws_ecs_cluster.hello_world.arn
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    desired_count                      = 1
    enable_ecs_managed_tags            = true
    enable_execute_command             = false
    health_check_grace_period_seconds  = 0
    name                               = "hello-world-service"
    platform_version                   = "LATEST"
    propagate_tags                     = "NONE"
    scheduling_strategy                = "REPLICA"
    task_definition                    = aws_ecs_task_definition.hello_world.id
    triggers                           = {}

    capacity_provider_strategy {
        base              = 0
        capacity_provider = "FARGATE"
        weight            = 1
    }

    deployment_circuit_breaker {
        enable   = true
        rollback = true
    }

    deployment_controller {
        type = "ECS"
    }

    network_configuration {
        assign_public_ip = true
        security_groups  = [
            "sg-0249dadc8df01c56b",
            "sg-06693f862ffb64532",
        ]
        subnets          = [
            "subnet-005fc72d40087a06c",
            "subnet-0068689ad015b15a1",
            "subnet-09e532f3238a4d9bb",
            "subnet-0b8e8e232e9208877",
            "subnet-0ceaf7e2df23f7dfd",
            "subnet-0fea0d32af4449bed",
        ]
    }
}

resource "aws_ecs_task_definition" "hello_world" {
    container_definitions    = jsonencode(
        [
            {
                cpu              = 0
                environment      = []
                environmentFiles = []
                essential        = true
                image            = "httpd"
                logConfiguration = {
                    logDriver     = "awslogs"
                    options       = {
                        awslogs-create-group  = "true"
                        awslogs-group         = "/ecs/hello-world"
                        awslogs-region        = "us-east-1"
                        awslogs-stream-prefix = "ecs"
                    }
                    secretOptions = []
                }
                mountPoints      = []
                name             = "hello-world"
                portMappings     = [
                    {
                        appProtocol   = "http"
                        containerPort = 80
                        hostPort      = 80
                        name          = "hello-world-80-tcp"
                        protocol      = "tcp"
                    },
                ]
                ulimits          = []
                volumesFrom      = []
            },
        ]
    )
    cpu                      = "256"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    family                   = "hello-world"
    memory                   = "512"
    network_mode             = "awsvpc"
    requires_compatibilities = [
        "FARGATE",
    ]

    runtime_platform {
        cpu_architecture        = "X86_64"
        operating_system_family = "LINUX"
    }
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name                  = "ecsTaskExecutionRole"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "ecs-tasks.amazonaws.com"
                    }
                    Sid       = ""
                },
            ]
            Version   = "2008-10-17"
        }
    )
    managed_policy_arns   = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    ]
}
