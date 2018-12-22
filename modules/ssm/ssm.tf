variable environment {
}

resource "aws_ssm_maintenance_window" "mw" {
  name     = "mw-${var.environment}-thurs-6pm-10pm"
  schedule = "cron(0 18 ? * THU *)"
  duration = 4
  cutoff   = 1
  allow_unassociated_targets = false
}

resource "aws_ssm_maintenance_window_target" "mw-target" {
  window_id     = "${aws_ssm_maintenance_window.mw.id}"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:environment"
    values = ["${var.environment}"]
  }
}

resource "aws_iam_service_linked_role" "ssm-service-role" {
  aws_service_name = "ssm.amazonaws.com"
}

resource "aws_ssm_maintenance_window_task" "mw-task" {
  window_id        = "${aws_ssm_maintenance_window.mw.id}"
  name             = "maintenance-window-task"
  description      = "This is a maintenance window task"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = "${aws_iam_service_linked_role.ssm-service-role.arn}"
  max_concurrency  = "1"
  max_errors       = "1"

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.mw-target.id}"]
  }

  task_parameters {
    name = "Operation"
    values = ["Install"]
  }
}
