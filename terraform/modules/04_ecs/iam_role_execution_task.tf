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