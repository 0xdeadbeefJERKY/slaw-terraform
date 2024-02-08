# LAB: Follow the Money!
resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = "billing-total-estimated-10usd"
  alarm_description   = "Alarm when AWS billing exceeds $10"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 21600
  statistic           = "Maximum"
  threshold           = 10
  namespace           = "AWS/Billing"
  metric_name         = "EstimatedCharges"
  alarm_actions       = [aws_sns_topic.default.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    currency = "USD"
  }
}
