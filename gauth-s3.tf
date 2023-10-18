resource "aws_s3_bucket" "gauth_s3_bucket" {
    bucket = var.gauth_data_s3

    tags = {
        name = "gauth_s3_bucket"
    }
}   