terraform {
    backend "s3" {
        # s3 bucket for storing state file
        bucket      = "tf-state-bkt-hostme"
        key         = "staging/services/webserver-cluster/terraform.tfstate"
        region      = "us-east-1"

        # DyanomDB for locks 
        dynamodb_table  = "tf-db-lock"
        encrypt         = "true"
    }
}

resource "aws_launch_configuration" "lconf_web" {
    image_id    =   "ami-01d025118d8e760db"
    instance_type =  var.instance_type
    security_groups = [aws_security_group.sg-web.id]
    #Using render file instead
    user_data = data.template_file.user-data.rendered
    
    lifecycle {
        create_before_destroy   = true
    }
        
}

resource "aws_autoscaling_group" "asg-web" {
    launch_configuration = aws_launch_configuration.lconf_web.name
    vpc_zone_identifier  = data.aws_subnet_ids.df-sub.ids
    target_group_arns   = [aws_lb_target_group.tar-grp-asg.arn]
    health_check_type   = "ELB"

    min_size = var.min_size
    max_size = var.max_size

    tag {
        key     = "Name"
        value   = "${var.cluster_name}-asg-web"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_schedule" "scale_outof_bus" {
    scheduled_action_name           = "scale-out-bus-hrs"
    min_size                        = 2
    max_size        = 4
    desired_capacity   = 4
    recurrence          = "0 9 * * *" 
}

resource "aws_autoscaling_schedule" "scale_in_night" {
    scheduled_action_name           = "scale-in-at-ngt"
    min_size                        = 1
    max_size        = 4
    desired_capacity   = 1
    recurrence          = "0 17 * * *" 
}

