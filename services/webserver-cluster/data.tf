data "aws_vpc" "df-vpc" {
    default = true
}

data "aws_subnet_ids" "df-sub" {
    vpc_id = data.aws_vpc.df-vpc.id
}

data "terraform_remote_state" "db" {
    backend         = "s3"

    config          = {
        bucket      =  var.db_remote_state_bucket 
        key         =  var.db_remote_state_key 
        region      = "us-east-1"
    }
}

data "template_file" "user-data" {
    count = var.enable_new_user_data ? 0 : 1

    template        = file("${path.module}/user-data.sh")

    vars            = {
        server_port = var.web-srv-prt
        db_address  = data.terraform_remote_state.db.outputs.address
        db_port     = data.terraform_remote_state.db.outputs.port
    }
}

data "template_file" "user-new-data.sh" {
    count = var.enable_new_user_data ? 1 : 0

    template        = file("${path.module}/user-new-data.sh")
    vars            = {
        server_port = var.web-srv-prt
        db_address  = data.terraform_remote_state.db.outputs.address
        db_port     = data.terraform_remote_state.db.outputs.port
        server_text  = var.server_text
    }
}