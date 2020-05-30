/*
output "public_ip" {
    value           = aws_instance.webserv.public_ip
    description     = "The public ip of the webserver"
}
*/

output "alb_dns_name" {
    value                       = aws_lb.web-lb.dns_name
    description                 = "The domain name of the load balancer"
}

output "asg_name" {
    value               = aws_autoscaling_group.asg-web.name
    description         = "The name of the Autoscaling group"
}

output "alb_dns_name" {
    value           = aws_lb.web-lb.dns_name
    description     = "The URL for the load balancer "
}