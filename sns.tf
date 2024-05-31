# LAB: Timmy's First CloudFormation
resource "aws_sns_topic" "default" {
  name = "SecurityAlerts"
}

# LAB: Follow the Money!
resource "aws_sns_topic_subscription" "billing" {
  topic_arn = aws_sns_topic.default.arn
  protocol  = "email"
  endpoint  = var.cloudwatch_email
}

# LAB: Use EventBridge for Security Hub Alerts
resource "aws_sns_topic" "security_hub_alerts" {
  provider = aws.sa

  name         = "SecurityHubAlerts"
  display_name = "SecurityHubAlerts"
}

resource "aws_sns_topic_subscription" "security_hub_alerts" {
  provider = aws.sa

  topic_arn = aws_sns_topic.security_hub_alerts.arn
  protocol  = "email"
  endpoint  = var.account_email
}

resource "aws_sns_topic_policy" "security_hub_alerts" {
  provider = aws.sa

  arn    = aws_sns_topic.security_hub_alerts.arn
  policy = data.aws_iam_policy_document.security_hub_alerts.json
}

data "aws_iam_policy_document" "security_hub_alerts" {
  statement {
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.security_hub_alerts.arn]
  }
}
