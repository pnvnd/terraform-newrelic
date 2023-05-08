terraform {
  required_version = "~> 1.3.6"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.20.2"
    }
  }
}

provider "newrelic" {
  account_id = var.new_relic_account_id
  api_key = var.new_relic_user_api_key
  region = var.new_relic_region
}