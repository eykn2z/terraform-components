// ciでecspresso実行するのに必要
data "aws_iam_user" "app" {
  user_name = "app"
}

resource "aws_iam_role" "ci_role" {
  name = "ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # Service = "ecs.amazonaws.com",
          AWS = data.aws_iam_user.app.arn
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_full_access" {
  role       = aws_iam_role.ci_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_policy" "ecs_pass_role_policy" {
  name        = "ECS_PassRole_Policy"
  description = "Policy to allow passing the ecsTaskExecutionRole"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["iam:PassRole", "iam:GetRole"]
        Resource = aws_iam_role.ecs_task_execution_role.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${aws_ecs_cluster.hello_world.name}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_pass_role_policy_attachment" {
  role       = aws_iam_role.ci_role.name
  policy_arn = aws_iam_policy.ecs_pass_role_policy.arn
}

resource "aws_iam_policy" "assume_ci_role_policy" {
  name        = "AssumeRolePolicyForCiRole"
  description = "Policy to allow assuming roles and tagging sessions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Resource = aws_iam_role.ci_role.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_assume_role_policy" {
  user       = data.aws_iam_user.app.user_name
  policy_arn = aws_iam_policy.assume_ci_role_policy.arn
}