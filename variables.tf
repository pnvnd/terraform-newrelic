variable "new_relic_license_key" {
    type = string
}

variable "new_relic_user_api_key" {
    type = string
}

variable "new_relic_account_id" {
    type = string
}

variable "new_relic_account_name" {
    type = string
    default = "Production"
}

variable "new_relic_region" {
    type = string
    default = "US"
}

variable "aws_region" {
    type = string
    default = "ca-central-1"
}

variable "team" {
    type = string
    default = "datacrunch-dev"
}