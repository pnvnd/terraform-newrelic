# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/synthetics_monitor

locals {  
  pingURLs = [
    { 
      name = "New Relic"
      uri = "https://newrelic.com"
    },
    { 
      name = "NR Developer Site"
      uri = "https://developer.newrelic.com"
    },
    { 
      name = "NR Learn Site"
      uri = "https://learn.newrelic.com"
    }
  ]
}

resource "newrelic_synthetics_monitor" "ping" {
  count                     = length(local.pingURLs)
  uri                       = local.pingURLs[count.index].uri
  
  name                      = "Example Ping ${local.pingURLs[count.index].name}"
  type                      = "SIMPLE"
  period                    = "EVERY_5_MINUTES"
  status                    = "ENABLED"

# https://docs.newrelic.com/docs/synthetics/synthetic-monitoring/administration/synthetic-public-minion-ips/#location
  locations_public          = ["AWS_US_EAST_1", "AP_SOUTH_1"]
     
  verify_ssl                = true
  bypass_head_request       = false
  treat_redirect_as_failure = false
  validation_string         = ""

  custom_header {
    name  = ""
    value = ""
  }

  tag {
      key    = "team"
      values = ["datacrunch"]
    }

  tag {
      key    = "APP-ID"
      values = ["12345"]
    }

}