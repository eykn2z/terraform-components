resource "aws_iam_role" "datadog_integration_role" {
  name = "DatadogIntegrationRole"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Condition = {
            StringEquals = {
              "sts:ExternalId" = "540c3e149aa048f7903df3bf545f719b"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::417141415827:root"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  inline_policy {
    name = "datadog-integration-policy"
    policy = jsonencode(
      {
        Statement = [
          {
            Action = [
              "apigateway:GET",
              "autoscaling:Describe*",
              "backup:List*",
              "budgets:ViewBudget",
              "cloudfront:GetDistributionConfig",
              "cloudfront:ListDistributions",
              "cloudtrail:DescribeTrails",
              "cloudtrail:GetTrailStatus",
              "cloudtrail:LookupEvents",
              "cloudwatch:Describe*",
              "cloudwatch:Get*",
              "cloudwatch:List*",
              "codedeploy:List*",
              "codedeploy:BatchGet*",
              "directconnect:Describe*",
              "dynamodb:List*",
              "dynamodb:Describe*",
              "ec2:Describe*",
              "ec2:GetTransitGatewayPrefixListReferences",
              "ec2:SearchTransitGatewayRoutes",
              "ecs:Describe*",
              "ecs:List*",
              "elasticache:Describe*",
              "elasticache:List*",
              "elasticfilesystem:DescribeFileSystems",
              "elasticfilesystem:DescribeTags",
              "elasticfilesystem:DescribeAccessPoints",
              "elasticloadbalancing:Describe*",
              "elasticmapreduce:List*",
              "elasticmapreduce:Describe*",
              "es:ListTags",
              "es:ListDomainNames",
              "es:DescribeElasticsearchDomains",
              "events:CreateEventBus",
              "fsx:DescribeFileSystems",
              "fsx:ListTagsForResource",
              "health:DescribeEvents",
              "health:DescribeEventDetails",
              "health:DescribeAffectedEntities",
              "kinesis:List*",
              "kinesis:Describe*",
              "lambda:GetPolicy",
              "lambda:List*",
              "logs:DeleteSubscriptionFilter",
              "logs:DescribeLogGroups",
              "logs:DescribeLogStreams",
              "logs:DescribeSubscriptionFilters",
              "logs:FilterLogEvents",
              "logs:PutSubscriptionFilter",
              "logs:TestMetricFilter",
              "organizations:Describe*",
              "organizations:List*",
              "rds:Describe*",
              "rds:List*",
              "redshift:DescribeClusters",
              "redshift:DescribeLoggingStatus",
              "route53:List*",
              "s3:GetBucketLogging",
              "s3:GetBucketLocation",
              "s3:GetBucketNotification",
              "s3:GetBucketTagging",
              "s3:ListAllMyBuckets",
              "s3:PutBucketNotification",
              "ses:Get*",
              "sns:List*",
              "sns:Publish",
              "sqs:ListQueues",
              "states:ListStateMachines",
              "states:DescribeStateMachine",
              "support:DescribeTrustedAdvisor*",
              "support:RefreshTrustedAdvisorCheck",
              "tag:GetResources",
              "tag:GetTagKeys",
              "tag:GetTagValues",
              "xray:BatchGetTraces",
              "xray:GetTraceSummaries",
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
        Version = "2012-10-17"
      }
    )
  }
}

data "aws_ssm_parameter" "dd_api_key" {
  name           = "/dd-api-key"
  with_decryption = true
}

resource "aws_cloudformation_stack" "datadog_forwarder" {
  name         = "datadog-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  parameters = {
    DdApiKey = data.aws_ssm_parameter.dd_api_key.value,
    DdSite            = "ap1.datadoghq.com",
    FunctionName      = "datadog-forwarder"
  }
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
}