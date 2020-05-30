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
    template        = file("${path.module}/user-data.sh")

    vars            = {
        server_port = var.web-srv-prt
        db_address  = data.terraform_remote_state.db.outputs.address
        db_port     = data.terraform_remote_state.db.outputs.port
    }
}