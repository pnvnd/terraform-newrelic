terraform {
  required_version = "~> 1.5.3"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.25.2"
    }
    aws = {
    source  = "hashicorp/aws"
    version = "~> 5.8.0"
    }
  }
}

provider "newrelic" {
  account_id = var.new_relic_account_id
  api_key = var.new_relic_user_api_key
  region = var.new_relic_region
}