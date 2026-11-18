###############################################################################
# logs

resource "aws_cloudwatch_log_group" "vpc" {
  name = "${local.name}-vpc-lg"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "ec2" {
  name = "${local.name}-ec2-lg"
  retention_in_days = var.log_retention_days
}

###############################################################################
# dashboard

###############################################################################
# dashboard

locals {
  monitored_instances = {
    dbserver  = aws_instance.dbserver.id
    appserver = aws_instance.appserver.id
  }

  # One line per server for an AWS/EC2 metric
  ec2_metrics = {
    for m in [
      "CPUUtilization", "CPUCreditBalance", "CPUCreditUsage",
      "NetworkIn", "NetworkOut", "EBSReadBytes", "EBSWriteBytes",
      "EBSReadOps", "EBSWriteOps", "StatusCheckFailed",
    ] : m => [
      for host, id in local.monitored_instances :
      ["AWS/EC2", m, "InstanceId", id, { label = "${host} ${m}" }]
    ]
  }

  # One SEARCH expression per server for a CWAgent metric.
  # Key = short id (used in metric ids), value = search term without InstanceId.
  cwagent_metrics = {
    for key, term in {
      mem       = "MetricName=\"mem_used_percent\""
      memavail  = "MetricName=\"mem_available_percent\""
      swap      = "MetricName=\"swap_used_percent\""
      disk      = "MetricName=\"disk_used_percent\" path=\"/\""
      inodes    = "MetricName=\"disk_inodes_free\" path=\"/\""
      iowait    = "MetricName=\"cpu_usage_iowait\""
      steal     = "MetricName=\"cpu_usage_steal\""
      cpuuser   = "MetricName=\"cpu_usage_user\""
      cpusys    = "MetricName=\"cpu_usage_system\""
      tcp       = "MetricName=\"netstat_tcp_established\""
      blocked   = "MetricName=\"processes_blocked\""
      procs     = "MetricName=\"procstat_lookup_pid_count\""
    } : key => [
      for host, id in local.monitored_instances : [{
        id         = "${key}_${host}"
        label      = host
        expression = "SEARCH('{CWAgent} ${term} InstanceId=\"${id}\"', 'Average', 60)"
      }]
    ]
  }

  dashboard_widget_defaults = {
    type   = "metric"
    width  = 8
    height = 6
  }
}

resource "aws_cloudwatch_dashboard" "servers" {
  dashboard_name = "${local.name}-servers"

  dashboard_body = jsonencode({
    widgets = [for w in [
      # Row 1: CPU
      { x = 0, y = 0, title = "CPU utilisation (%)", max = 100,
        metrics = local.ec2_metrics["CPUUtilization"] },
      { x = 8, y = 0, title = "CPU user / system / iowait / steal (%)", max = 100,
        metrics = concat(local.cwagent_metrics["cpuuser"], local.cwagent_metrics["cpusys"],
                         local.cwagent_metrics["iowait"], local.cwagent_metrics["steal"]) },
      { x = 16, y = 0, title = "CPU credit balance / usage", period = 300,
        metrics = concat(local.ec2_metrics["CPUCreditBalance"], local.ec2_metrics["CPUCreditUsage"]) },

      # Row 2: memory and storage
      { x = 0, y = 6, title = "Memory used / available (%)", max = 100,
        metrics = concat(local.cwagent_metrics["mem"], local.cwagent_metrics["memavail"]) },
      { x = 8, y = 6, title = "Swap used (%)", max = 100,
        metrics = local.cwagent_metrics["swap"] },
      { x = 16, y = 6, title = "Root disk used (%)", max = 100,
        metrics = local.cwagent_metrics["disk"] },

      # Row 3: I/O and network
      { x = 0, y = 12, title = "EBS read / write (bytes)", stat = "Sum",
        metrics = concat(local.ec2_metrics["EBSReadBytes"], local.ec2_metrics["EBSWriteBytes"]) },
      { x = 8, y = 12, title = "EBS read / write (ops)", stat = "Sum",
        metrics = concat(local.ec2_metrics["EBSReadOps"], local.ec2_metrics["EBSWriteOps"]) },
      { x = 16, y = 12, title = "Network in / out (bytes)", stat = "Sum",
        metrics = concat(local.ec2_metrics["NetworkIn"], local.ec2_metrics["NetworkOut"]) },

      # Row 4: processes and health
      { x = 0, y = 18, title = "Processes (postgres / Airflow components)",
        metrics = local.cwagent_metrics["procs"] },
      { x = 8, y = 18, title = "TCP established / blocked processes",
        metrics = concat(local.cwagent_metrics["tcp"], local.cwagent_metrics["blocked"]) },
      { x = 16, y = 18, title = "Status check failed / free inodes", stat = "Maximum",
        metrics = concat(local.ec2_metrics["StatusCheckFailed"], local.cwagent_metrics["inodes"]) },
    ] : merge(local.dashboard_widget_defaults, {
      x = w.x
      y = w.y
      properties = {
        title   = w.title
        region  = var.aws_region
        view    = "timeSeries"
        stacked = false
        period  = lookup(w, "period", 60)
        stat    = lookup(w, "stat", "Average")
        metrics = w.metrics
        yAxis   = { left = merge({ min = 0 }, can(w.max) ? { max = w.max } : {}) }
      }
    })]
  })
}


