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
  tag_map = local.tags
}


locals {
  name = module.tags.name
  tags = module.tags.tags
  security_group_ids = concat(
    [aws_security_group.this.id],
    var.additional_security_group_ids
  )
}

resource "aws_security_group" "this" {
  name_prefix = local.name
  description = "Allow outbound access to anything on port 443 for SSM"

  vpc_id = var.vpc_id
  tags   = local.tags

  egress {
    description      = "Allow all outbound 443"
    cidr_blocks      = ["0.0.0.0/0"] # tfsec:ignore:AWS009
    ipv6_cidr_blocks = ["::/0"]      # tfsec:ignore:AWS009
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name_prefix = substr(local.name, 0, 32)
  description = "Allows SSM access"

  assume_role_policy  = data.aws_iam_policy_document.assume.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  tags                = local.tags
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = local.name
  role        = aws_iam_role.this.name
  tags        = local.tags
}

resource "aws_launch_template" "this" {
  name_prefix = local.name
  description = coalesce(var.launch_template_description, local.name)

  update_default_version = true
  ebs_optimized          = true
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = local.security_group_ids
  tags                   = local.tags
  user_data              = var.user_data

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings

    content {
      device_name = each.value.device_name

      ebs {
        delete_on_termination = coalesce(each.value.delete_on_termination, true)
        encrypted             = coalesce(each.value.encrypted, true)
        iops                  = each.value.iops
        kms_key_id            = each.value.kms_key_id
        snapshot_id           = each.value.snapshot_id
        throughput            = each.value.throughput
        volume_size           = each.value.volume_size
        volume_type           = coalesce(each.value.volume_type, "gp3")
      }
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  dynamic "iam_instance_profile" {
    for_each = var.additional_iam_instance_profile_arns

    content {
      arn = each.value
    }
  }

  monitoring {
    enabled = var.detailed_monitoring_enabled
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "spot-instances-request"
    tags          = local.tags
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix = local.name

  # Capacity and Scaling
  default_cooldown = var.scaling_cooldown
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  # Load Balancers
  target_group_arns = var.target_group_arns

  # Health
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  max_instance_lifetime     = var.max_instance_lifetime
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  dynamic "instance_refresh" {
    for_each = [var.instance_refresh]
    content {
      strategy = instance_refresh.value.strategy
      triggers = instance_refresh.value.triggers

      dynamic "preferences" {
        for_each = [instance_refresh.value.preferences]
        content {
          instance_warmup        = preferences.value.instance_warmup
          min_healthy_percentage = preferences.value.min_healthy_percentage
        }
      }
    }
  }

  # ASG Config
  service_linked_role_arn = var.service_linked_role_arn
  suspended_processes     = var.suspended_processes
  tags                    = module.asg_tags.tag_list
  vpc_zone_identifier     = var.vpc_zone_identifier

  # Instance Definition
  dynamic "launch_template" {
    for_each = var.mixed_instances_policy == null ? [1] : []
    content {
      id = aws_launch_template.this.id
    }
  }

  # Mixed Instances
  capacity_rebalance = var.mixed_instances_policy != null

  dynamic "mixed_instances_policy" {
    for_each = toset([var.mixed_instances_policy])
    content {
      dynamic "instances_distribution" {
        for_each = toset([mixed_instances_policy.value.instances_distribution])
        content {
          on_demand_allocation_strategy            = instances_distribution.value.on_demand_allocation_strategy
          on_demand_base_capacity                  = instances_distribution.value.on_demand_base_capacity
          on_demand_percentage_above_base_capacity = instances_distribution.value.on_demand_percentage_above_base_capacity
          spot_allocation_strategy                 = instances_distribution.value.spot_allocation_strategy
          spot_instance_pools                      = instances_distribution.value.spot_instance_pools
          spot_max_price                           = instances_distribution.value.spot_max_price
        }
      }
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.this.id
        }
        dynamic "override" {
          for_each = mixed_instances_policy.value.override
          content {
            instance_type     = override.value.instance_type
            weighted_capacity = override.value.weighted_capacity
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}
