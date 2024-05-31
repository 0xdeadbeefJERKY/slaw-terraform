# LAB: Use EventBridge for Security Hub Alerts
resource "aws_cloudwatch_event_rule" "security_hub_alerts" {
  provider = aws.sa

  name        = "SecurityHubFindings"
  description = "All findings from Security Hub"

  event_pattern = jsonencode({
    "source"      = ["aws.securityhub"],
    "detail-type" = ["Security Hub Findings - Imported"]
  })
}

resource "aws_cloudwatch_event_target" "security_hub_alerts" {
  provider = aws.sa

  rule = aws_cloudwatch_event_rule.security_hub_alerts.name
  arn  = aws_sns_topic.security_hub_alerts.arn
}
