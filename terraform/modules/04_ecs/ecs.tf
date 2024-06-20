resource "aws_ecs_cluster" "hello_world" {
    name = "hello-world"

    configuration {
    execute_command_configuration {
        logging = "DEFAULT"
      }
  }
}

data "aws_vpc" "default" {
  id = "vpc-083c10fab309ccfc5"
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# data "aws_security_groups" "default" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }

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
            //default
            "sg-078d37c9ebd0f3947",
            // out 80
            # "sg-05e71cdb2ab5ca05e",
            ]
        subnets          = data.aws_subnets.default.ids
    }

#   lifecycle {
#     ignore_changes = [task_definition]
#   }
}

resource "aws_ecs_task_definition" "hello_world" {
    family                   = "hello-world"
    cpu                      = "256"
    memory                   = "512"
    network_mode             = "awsvpc"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    requires_compatibilities = ["FARGATE"]
    runtime_platform {
        cpu_architecture        = "X86_64"
        operating_system_family = "LINUX"
    }
    track_latest = true
    container_definitions    = jsonencode(
        [
            {
                image            = "791848147212.dkr.ecr.us-east-1.amazonaws.com/api-server:latest"
                logConfiguration = {
                    logDriver     = "awslogs"
                    options       = {
                        awslogs-create-group  = "true"
                        awslogs-group         = "/aws/ecs/hello-world"
                        awslogs-region        = "us-east-1"
                        awslogs-stream-prefix = "ecs"
                    }
                    secretOptions = []
                }
                mountPoints      = []
                name             = "hello-world"
                # portMappings     = [
                #     {
                #         appProtocol   = "http"
                #         containerPort = 80
                #         hostPort      = 80
                #         name          = "hello-world-80-tcp"
                #         protocol      = "tcp"
                #     },
                # ]
                ulimits          = []
                volumesFrom      = []
            },
        ]
    )
    lifecycle {
    ignore_changes = [
      container_definitions
    ]
  }
}