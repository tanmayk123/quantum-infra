terraform {
  backend "s3" {
    bucket         = "terraform-state-quantum-dev"
    key            = "statefile/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks-quantun"
    encrypt        = true
  }
}
