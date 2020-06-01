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

/*
    PURPOSE: Launch Config
    DESC: All the settings required to configure ASG vms/instance
*/
resource "aws_launch_configuration" "lconf_web" {
    image_id    =   var.ami
    instance_type =  var.instance_type
    security_groups = [aws_security_group.sg-web.id]
    #Using render file instead
    user_data = (length(data.template_file.user_data[*]) > 0 ?
                data.template_file.user_data[0].rendered
                : data.template_file.user_data_new[0].rendered)
    
    lifecycle {
        create_before_destroy   = true
    }
        
}

/* 
    PURPOSE: Setup AutoScaling Group

*/
resource "aws_autoscaling_group" "asg-web" {
    launch_configuration = aws_launch_configuration.lconf_web.name
    vpc_zone_identifier  = data.aws_subnet_ids.df-sub.ids
    target_group_arns   = [aws_lb_target_group.tar-grp-asg.arn]
    health_check_type   = "ELB"

    min_size = var.min_size
    max_size = var.max_size

    min_elb_capcity    = var.min_size

    lifecycle {
        create_before_destroy   = true
    }

    dynamic "tag" {
        for_each = var.custom_tags

        content {
                key                     = tag.value
                value                   = tag.value
                propagate_at_launch     = true
        }
    }

    tag {
        key     = "Name"
        value   = "${var.cluster_name}-asg-web"
        propagate_at_launch = true
    }
}


/* 
    if statement , <CONDITION> ? <TRUE> : <FALSE>
    if enable_autoscaling returns True (1), false (0)
*/
resource "aws_autoscaling_schedule" "scale_outof_bus" {
    count   = var.enable_autoscaling ? 1 : 0

    scheduled_action_name           = "scale-out-bus-hrs"
    min_size                        = 2
    max_size        = 4
    desired_capacity   = 4
    recurrence          = "0 9 * * *" 

    autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_night" {
    count   = var.enable_autoscaling ? 1 : 0
    scheduled_action_name           = "scale-in-at-ngt"
    min_size                        = 1
    max_size        = 4
    desired_capacity   = 1
    recurrence          = "0 17 * * *" 

    autoscaling_group_name = module.webserver_cluster.asg_name
}