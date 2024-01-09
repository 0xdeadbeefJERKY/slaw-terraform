# LAB: Follow the Money!
resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = "billing-total-estimated"
  alarm_description   = "Monitor total estimated billing charges"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 28800
  statistic           = "Maximum"
  threshold           = 25
  namespace           = "AWS/Billing"
  metric_name         = "EstimatedCharges"
  alarm_actions       = [aws_sns_topic.default.arn]

  dimensions = {
    currency = "USD"
  }
}
