resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
    alarm_name       = "${var.cluster_name}-high_cpu_utilization"
    namespace        = "AWS/EC2"
    metric_name      = "CPUUtilization"

    dimensions = {
        AutoScalingGroupName    = aws_autoscaling_group.asg-web.name
    } 

    comparison_operator         = "GreaterThanThreshold"
    evaluation_periods           = 1
    period                      = 300
    statistic                   = "Average"
    threshold                    = 90
    unit                        = "Percent"
}

/* 
    if statement: chcking for "t" cpu credit balance, have to make sure it create the resource
    "%.1" parses out the first letter of the string t2.microsls
    
*/

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
    count = format("%.1s", var.instance_type) == "t" ? 1 : 0

    alarm_name  = "${var.cluster_name}-low_cpu_credit_balance"
    namespace   = "AWS/EC2"
    metric_name = "CPUCreditBalance"

    dimensions = {
        AutoScalingGroupName    = aws_autoscaling_group.asg-web.name
    }
    
    comparison_operator         = "LessThanThreshold"
    evaluation_periods           = 1
    period                      = 300
    statistic                   = "Minimum"
    threshold                    = 10
    unit                        = "Count"
}