terraform {
  required_version = "~> 1.1"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.44" 
    }
  }
}

provider "newrelic" {
  account_id = var.new_relic_account_id
  api_key = var.new_relic_user_api_key
  region = var.new_relic_region
}
