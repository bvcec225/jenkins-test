variable "bucket_name" {
  default = "my-terraform-s3-bucket"
  type = string
  description = "bucket name"
  }

variable "environment" {
  description = "Environment name"
  type        = string
}