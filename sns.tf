# LAB: Timmy's First CloudFormation
resource "aws_sns_topic" "default" {
  name = "SecurityAlerts"
}
