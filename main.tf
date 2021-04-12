module "tags" {
  source  = "rhythmictech/tags/terraform"
  version = "~> 1.1.0"

  enforce_case = "UPPER"
  names        = [var.name]
  tags         = var.tags
}

module "asg_tags" {
  source  = "rhythmictech/asg-tag-transform/aws"
  version = "1.0.0"
  tag_map = module.tags.tags
}

locals {
  # tflint-ignore: terraform_unused_declarations
  name = module.tags.name
  # tflint-ignore: terraform_unused_declarations
  tags = module.tags.tags_no_name
}

resource "aws_autoscaling_group" "this" {
  name_prefix = var.name

  # Capacity and Scaling
  default_cooldown = var.scaling_cooldown
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  # Instance Definition
  launch_configuration = var.launch_configuration
  launch_template      = var.launch_template

  # Load Balancers
  target_group_arns = var.target_group_arns

  # Health
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  instance_refresh          = var.instance_refresh
  max_instance_lifetime     = var.max_instance_lifetime
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  # ASG Config
  service_linked_role_arn = var.service_linked_role_arn
  suspended_processes     = var.suspended_processes
  tags                    = module.asg_tags.tag_list
  vpc_zone_identifier     = var.vpc_zone_identifier

  # Mixed Instances
  capacity_rebalance     = var.mixed_instances_policy != null
  mixed_instances_policy = var.mixed_instances_policy

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}
