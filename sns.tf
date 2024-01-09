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
