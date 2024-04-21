/*

    This is a modification to this example:
    https://github.com/newrelic/terraform-provider-newrelic/blob/main/examples/cloud-integrations-aws.tf
    Complete example to enable AWS integration with New Relic

*/

variable "NEW_RELIC_CLOUDWATCH_LOG_ENDPOINT" {
  type = string
  # Depending on where your New Relic Account is located you need to change the default
  default = "https://aws-api.newrelic.com/firehose/v1" # US Datacenter
  # default = "https://aws-api.eu.newrelic.com/firehose/v1" # EU Datacenter
}

data "aws_iam_policy_document" "newrelic_assume_policy_log" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      // This is the unique identifier for New Relic account on AWS, there is no need to change this
      identifiers = [754728514883]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.new_relic_account_id]
    }
  }
}

resource "aws_iam_role" "newrelic_aws_role_log" {
  name               = "NewRelicInfrastructure-LogIntegrations"
  description        = "New Relic Cloud integration role"
  assume_role_policy = data.aws_iam_policy_document.newrelic_assume_policy_log.json
}

resource "aws_iam_policy" "newrelic_aws_permissions_log" {
  name        = "NewRelicCloudStreamReadPermissionsLog"
  description = ""
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "budgets:ViewBudget",
        "cloudtrail:LookupEvents",
        "config:BatchGetResourceConfig",
        "config:ListDiscoveredResources",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeVpcs",
        "ec2:DescribeNatGateways",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeSubnets",
        "ec2:DescribeNetworkAcls",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeVpnConnections",
        "health:DescribeAffectedEntities",
        "health:DescribeEventDetails",
        "health:DescribeEvents",
        "tag:GetResources",
        "xray:BatchGet*",
        "xray:Get*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "newrelic_aws_policy_attach_log" {
  role       = aws_iam_role.newrelic_aws_role_log.name
  policy_arn = aws_iam_policy.newrelic_aws_permissions_log.arn
}

resource "newrelic_api_access_key" "newrelic_aws_log_access_key" {
  account_id  = var.new_relic_account_id
  key_type    = "INGEST"
  ingest_type = "LICENSE"
  name        = "Ingest License key"
  notes       = "AWS Cloud Integrations Firehose Key"
}

resource "aws_iam_role" "firehose_newrelic_log_role" {
  name = "firehose_newrelic_log_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "random_string" "s3-bucket-name-log" {
  length = 8
  special = false
  upper = false
}

resource "aws_s3_bucket" "newrelic_aws_bucket_logs" {
  bucket = "newrelic-aws-bucket-logs-${random_string.s3-bucket-name-log.id}"
}

resource "aws_s3_bucket_ownership_controls" "newrelic_ownership_controls_log" {
  bucket = aws_s3_bucket.newrelic_aws_bucket_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "newrelic_firehose_log_stream" {
  name        = "newrelic_firehose_log_stream"
  destination = "http_endpoint"

  http_endpoint_configuration {
    url                = var.NEW_RELIC_CLOUDWATCH_LOG_ENDPOINT
    name               = "New Relic Logs"
    access_key         = newrelic_api_access_key.newrelic_aws_log_access_key.key
    buffering_size     = 1
    buffering_interval = 60
    role_arn           = aws_iam_role.firehose_newrelic_log_role.arn
    s3_backup_mode     = "FailedDataOnly"
    s3_configuration {
      role_arn           = aws_iam_role.firehose_newrelic_log_role.arn
      bucket_arn         = aws_s3_bucket.newrelic_aws_bucket_logs.arn
      buffering_size     = 10
      buffering_interval = 400
      compression_format = "GZIP"
  }
    request_configuration {
      content_encoding = "GZIP"
    }
  }
}

resource "aws_iam_role" "log_stream_to_firehose" {
  name = "log_stream_to_firehose_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "logs.${var.aws_region}.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "log_stream_to_firehose" {
  name = "default"
  role = aws_iam_role.log_stream_to_firehose.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": "${aws_kinesis_firehose_delivery_stream.newrelic_firehose_log_stream.arn}"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_log_subscription_filter" "newrelic_logfilter_1" {
  name            = "newrelic-logfilter"
  role_arn        = aws_iam_role.log_stream_to_firehose.arn
  log_group_name  = "/aws/lambda/lambda-python-demo"
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.newrelic_firehose_log_stream.arn
}

# resource "aws_cloudwatch_log_subscription_filter" "newrelic_logfilter_2" {
#   name            = "newrelic-logfilter"
#   role_arn        = aws_iam_role.log_stream_to_firehose.arn
#   log_group_name  = "/aws/batch/job"
#   filter_pattern  = ""
#   destination_arn = aws_kinesis_firehose_delivery_stream.newrelic_firehose_log_stream.arn
# }
