locals {
    http_port       = 80
    any_port        = 0
    any_protocol    = "-1"
    tcp_protocol    = "tcp"
    all_ips         = ["0.0.0.0/0"]

}

variable "web-srv-prt" {
    description = "the HTTP port for web services"
    type = number
    default = 8080
}

variable "cluster_name" {
    description         = "Name to use for all cluster resources"
    type                = string
}

variable "db_remote_state_bucket" {
    description         = "Name of the S3 bucket for the DB's remote state"
    type                = string
}

variable "db_remote_state_key" {
    description         = "The path for the DB remote state in S3"
    type               = string
    }

variable "instance_type" {
    description         = "The type of EC2 instance to run"
    type                = string
}

variable "min_size" {
    description         = "The minimal number of instances in the web cluster"
    type                = number
}

variable "max_size" {
    description         = "The maximum number of instances in the web cluster"
    type                = number
}

variable "custom_tags" {
    description     = "custom tags to set on Instance ASG"
    type            = map(string)
    default         = {}
}

#used to determine if enabling schedule task should be turned on for staging/prod
variable "enable_autoscaling" {
    description     = "if set to true, enable auto scaling"
    type            = bool
}

#used to determine if using 
variable "enable_new_user_data" {
    description     = "if this is true, use the new user data script"
    type            = bool
}

variable "ami" {
    description     = "The AMI to run in the web cluster"
    type            = string
    default         = "ami-01d025118d8e760db"
}

variable "server_text" {
    description     = "The text the server should respond"
    type            = string
    default         = "this shit works"
}