resource "newrelic_alert_policy" "golden_signals" {
  name = "Golden Signals"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

resource "newrelic_nrql_alert_condition" "traffic" {
  account_id                     = var.new_relic_account_id
  policy_id                      = newrelic_alert_policy.golden_signals.id
  type                           = "baseline"
  name                           = "Golden Signal - Traffic"
  description                    = "Alert when throughput changes"
  enabled                        = true
  runbook_url                    = "https://www.example.com"
  violation_time_limit_seconds   = 3000
  fill_option                    = "none"
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  baseline_direction             = "upper_and_lower"

  nrql {
    query = "select average(newrelic.goldenmetrics.apm.application.throughput) from Metric facet appName"
  }

  critical {
    operator              = "above"
    threshold             = 3
    threshold_duration    = 120
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 2
    threshold_duration    = 120
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "latency" {
  account_id                     = var.new_relic_account_id
  policy_id                      = newrelic_alert_policy.golden_signals.id
  type                           = "baseline"
  name                           = "Golden Signal - Latency (High Response Time)"
  description                    = "Alert when response time spikes"
  enabled                        = true
  runbook_url                    = "https://www.example.com"
  violation_time_limit_seconds   = 3000
  fill_option                    = "none"
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  baseline_direction             = "upper_only"

  nrql {
    query = "select average(newrelic.goldenmetrics.apm.application.responseTimeMs) from Metric facet appName"
  }

  critical {
    operator              = "above"
    threshold             = 3
    threshold_duration    = 180
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 2
    threshold_duration    = 180
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "errors" {
  account_id                     = var.new_relic_account_id
  policy_id                      = newrelic_alert_policy.golden_signals.id
  type                           = "baseline"
  name                           = "Golden Signal - Errors"
  description                    = "Alert when throughput changes"
  enabled                        = true
  runbook_url                    = "https://www.example.com"
  violation_time_limit_seconds   = 3000
  fill_option                    = "last_value"
  aggregation_method             = "event_flow"
  aggregation_delay              = 60
  baseline_direction             = "upper_only"

  nrql {
    query = "select count(apm.service.error.count)/count(apm.service.transaction.duration) from Metric where appName like '%' facet appName"
  }

  critical {
    operator              = "above"
    threshold             = 3
    threshold_duration    = 240
    threshold_occurrences = "at_least_once"
  }

  warning {
    operator              = "above"
    threshold             = 2
    threshold_duration    = 240
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "saturation" {
  account_id                     = var.new_relic_account_id
  policy_id                      = newrelic_alert_policy.golden_signals.id
  name                           = "Golden Signal - Saturation (High CPU)"

  # Define your signal
  nrql {
    query = "select average(host.cpuPercent) from Metric facet entity.name"
  }

  # Set your condition thresholds
  type                           = "static"

  critical {
    operator              = "above"
    threshold             = 85
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  # expiration_duration            = 600
  # close_violations_on_expiration = true
  # open_violation_on_expiration   = true

  # Fine-tune advanced signal settings

  ## Data Aggregation Settings
  aggregation_window             = 60
  # slide_by                       = 30
  aggregation_method             = "event_flow"
  aggregation_delay              = 60

  ## Gap-filling strategy
  fill_option                    = "static"
  fill_value                     = 0

  # Additional settings
  description                    = "Alert when CPU is under load"
  runbook_url                    = "https://www.example.com"
  violation_time_limit_seconds   = 7200

  enabled                        = true
}