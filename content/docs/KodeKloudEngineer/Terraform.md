---
title: Terraform Level 4
type: docs
prev: docs/KodeKloudEngineer/
next: docs/KodeKloudEngineer/Module2
sidebar:
  open: true
---

Terraform Level 4

## Alerting in CI/CD Pipelines Using Terraform

1.) Kinesis Firehose:
Create a delivery stream named nautilus-firehose.
It should deliver data to an S3 bucket as a staging area.

2.) S3 Bucket:
Create a bucket named nautilus-staging-9056 (value to come from variables).
Set private ACL and allow Firehose to write objects into it.
3.) IAM Role and Policy:
Create a role nautilus-firehose-role and a policy nautilus-firehose-policy with least privilege to allow Firehose to write to the staging bucket.
4.) CloudWatch Alarm:
Create a cloudwatch Alarm named nautilus-firehose-failures.
Monitor the Firehose delivery failures metric (DeliveryToS3.Failures) and trigger when failures occur.
5.) SNS Topic:
Create a topic nautilus-alert-topic and link the CloudWatch alarm to it.
6.) SES Email Identity:
Create an SES email identity named nautilus@example.comand verify an SES email identity using an email address provided in the variables.
7.) SNS Subscription:
Subscribe the verified SES email identity to the SNS topic to receive notifications.
8.) Use main.tf file to define all AWS resources and to ensure a clean and modular setup.
9.) Use variables.tf file with the following variables:
KKE_STAGING_BUCKET_NAME: Name of the S3 bucket for staging data.
KKE_FIREHOSE_ROLE_NAME: Name of the IAM role for the Firehose delivery stream.
KKE_FIREHOSE_POLICY_NAME: Name of the IAM policy for the Firehose delivery stream.
KKE_FIREHOSE_NAME: Name of the Kinesis Firehose delivery stream.
KKE_SNS_TOPIC_NAME: Name of the SNS topic for alerts.
KKE_CLOUDWATCH_ALARM_NAME: Name of the CloudWatch alarm to monitor Firehose delivery failures.
KKE_ALERT_EMAIL: Email address to receive SNS alerts through SES.
10.) Use terraform.tfvarsto input the value of the variables used in the variables.tf.
11.) Use outputs.tf file to output the following:
kke_staging_bucket_name:name of the bucket used.
kke_firehose_name:name of the firehose delivery stream used.
kke_sns_topic_name:name of the sns topic used.
kke_cloudwatch_alarm_name:name of the cloudwatch used.
kke_ses_identity:name of the ses identity used.
Notes:
The Terraform working directory is /home/bob/terraform.
Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
Before submitting the task, ensure that terraform plan returns `No changes. Your infrastructure matches the configuration


```

# main.tf

 

resource "aws_s3_bucket" "staging" {
  bucket = var.KKE_STAGING_BUCKET_NAME
}

resource "aws_s3_bucket_acl" "staging_acl" {
  bucket = aws_s3_bucket.staging.id
  acl    = "private"
}

resource "aws_iam_policy" "firehose_policy" {
  name = var.KKE_FIREHOSE_POLICY_NAME
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.staging.arn,
          "${aws_s3_bucket.staging.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "firehose_role" {
  name = var.KKE_FIREHOSE_ROLE_NAME
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  name        = var.KKE_FIREHOSE_NAME
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.staging.arn
  }
}

resource "aws_cloudwatch_metric_alarm" "firehose_failures" {
  alarm_name          = var.KKE_CLOUDWATCH_ALARM_NAME
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DeliveryToS3.Success"
  namespace           = "AWS/Firehose"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alarm when Firehose delivery to S3 fails"
  dimensions = {
    DeliveryStreamName = aws_kinesis_firehose_delivery_stream.firehose.name
  }
  alarm_actions = [aws_sns_topic.alert.arn]
}

resource "aws_sns_topic" "alert" {
  name = var.KKE_SNS_TOPIC_NAME
}

resource "aws_ses_email_identity" "email" {
  email = var.KKE_ALERT_EMAIL
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alert.arn
  protocol  = "email"
  endpoint  = var.KKE_ALERT_EMAIL
}

```

```
# variables.tf

variable "KKE_STAGING_BUCKET_NAME" {
  type = string
}

variable "KKE_FIREHOSE_ROLE_NAME" {
  type = string
}

variable "KKE_FIREHOSE_POLICY_NAME" {
  type = string
}

variable "KKE_FIREHOSE_NAME" {
  type = string
}

variable "KKE_SNS_TOPIC_NAME" {
  type = string
}

variable "KKE_CLOUDWATCH_ALARM_NAME" {
  type = string
}

variable "KKE_ALERT_EMAIL" {
  type = string
}

```

```
# terraform.tfvars

KKE_STAGING_BUCKET_NAME = "nautilus-staging-9056"
KKE_FIREHOSE_ROLE_NAME = "nautilus-firehose-role"
KKE_FIREHOSE_POLICY_NAME = "nautilus-firehose-policy"
KKE_FIREHOSE_NAME = "nautilus-firehose"
KKE_SNS_TOPIC_NAME = "nautilus-alert-topic"
KKE_CLOUDWATCH_ALARM_NAME = "nautilus-firehose-failures"
KKE_ALERT_EMAIL = "nautilus@example.com"

```

```
# outputs.tf

output "kke_staging_bucket_name" {
  value = aws_s3_bucket.staging.bucket
}

output "kke_firehose_name" {
  value = aws_kinesis_firehose_delivery_stream.firehose.name
}

output "kke_sns_topic_name" {
  value = aws_sns_topic.alert.name
}

output "kke_cloudwatch_alarm_name" {
  value = aws_cloudwatch_metric_alarm.firehose_failures.alarm_name
}

output "kke_ses_identity" {
  value = aws_ses_email_identity.email.email
}

```

```
terraform init
terraform validate
terraform plan
terraform apply
```