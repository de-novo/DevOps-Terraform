terraform {
  backend "s3" {
    bucket         = "hoit-apnortheast2-tfstate"
    key            = "hoit/terraform/services/medicine-search-server/dev/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
