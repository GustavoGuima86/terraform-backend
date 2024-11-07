# in the first run this block have to be commented to create teh structure to the backend
# after run terraform init -migrate-state
terraform {
    backend "s3" {
        bucket = "gustavo-terraform-backend"
        key    = "s3/terraform.tfstate"
        region = "eu-central-1"
        dynamodb_table = "terraform-lock"
    }
}


resource "aws_s3_bucket" "terraform_state_bucket" {
    bucket = "gustavo-terraform-state-backend"
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
    bucket = aws_s3_bucket.terraform_state_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket_encryption" {
    bucket = aws_s3_bucket.terraform_state_bucket.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_dynamodb_table" "terraform-lock" {
    name           = "terraform_state"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        "Name" = "DynamoDB Terraform State Lock Table"
    }
}