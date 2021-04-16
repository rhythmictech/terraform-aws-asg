
variable "name" {
  description = "Moniker to apply to all resources in the module"
  type        = string
}

################################
# Network
################################

variable "vpc_id" {
  description = "ID of VPC to use"
  type        = string
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside."
  type        = list(string)
}

################################
# Capacity and Scaling
################################
variable "scaling_cooldown" {
  default     = null
  description = "(Optional) The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
  type        = number
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group."
  type        = number
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group"
  type        = number
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group"
  type        = number
}

################################
# Instance Definition
################################

variable "additional_security_group_ids" {
  default     = []
  description = "A list of Security Group IDs to add in addition to the default. (Default only allows access to SSM)"
  type        = list(string)
}

variable "ami_id" {
  description = "ID of the AMI to use in the launch template"
  type        = string
}

variable "additional_iam_policy_arns" {
  default     = []
  description = "A list of IAM managed policy ARNs to add to the instances in adition to the default. Default allows SSM"
  type        = list(string)
}

variable "block_device_mappings" {
  default     = []
  description = "A list of objects describing any additional EBS volumes to mount to the instances"
  type = set(object({
    delete_on_termination = optional(bool)
    encrypted             = optional(bool)
    iops                  = optional(number)
    kms_key_id            = optional(string)
    snapshot_id           = optional(string)
    throughput            = optional(number)
    volume_size           = number
    volume_type           = optional(string)
  }))
}

variable "detailed_monitoring_enabled" {
  default     = false
  description = "Whether to enable detailed monitoring on instances"
  type        = bool
}

variable "instance_type" {
  description = "What instance type to use by default"
  type        = string
}

variable "key_name" {
  default     = null
  description = "The name of the SSH key to use in the launch template"
  type        = string
}

variable "launch_template_description" {
  default     = null
  description = "A description to attach to the launch template"
  type        = string
}

variable "user_data" {
  default     = null
  description = "The Base64-encoded user data to provide when launching the instance."
  type        = string
}

################################
# Load Balancers
################################

variable "target_group_arns" {
  default     = null
  description = "A set of aws_alb_target_group ARNs, for use with Application or Network Load Balancing."
  type        = set(string)
}

################################
# Health
################################

variable "health_check_grace_period" {
  default     = 300
  description = "Time in sconds after instance comes into service before checking health"
  type        = number
}

variable "health_check_type" {
  default     = "ELB"
  description = "(Optional) `EC2` or `ELB`. Controls how health checking is done."
  type        = string
}

variable "instance_refresh" {
  description = "(Optional) If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated. This resource does not wait for the instance refresh to complete."

  type = object({
    strategy = string
    triggers = optional(set(string))

    preferences = optional(object({
      instance_warmup        = optional(number)
      min_healthy_percentage = optional(number)
    }))
  })

  default = {
    strategy = "Rolling"
  }
}

variable "max_instance_lifetime" {
  default     = null
  description = "(Optional) The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds."
  type        = number
}

variable "wait_for_capacity_timeout" {
  default     = "10m"
  description = "(Default: `10m`) A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to `0` causes Terraform to skip all Capacity Waiting behavior."
  type        = string
}

################################
# ASG Config
################################

variable "service_linked_role_arn" {
  default     = null
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
  type        = string
}

variable "suspended_processes" {
  default     = []
  description = "A list of processes to suspend for the ASG. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`"
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = "User-Defined tags"
  type        = map(string)
}

################################
# Mixed Instances
################################

variable "mixed_instances_policy" {
  default     = null
  description = "Object defining how to mix on-demand and spot instances of different types"

  type = object({
    instances_distribution = optional(object({
      on_demand_allocation_strategy            = optional(string)
      on_demand_base_capacity                  = optional(number)
      on_demand_percentage_above_base_capacity = optional(number)
      spot_allocation_strategy                 = optional(string)
      spot_instance_pools                      = optional(number)
      spot_max_price                           = optional(string)
    }))

    override = list(object({
      instance_type     = optional(string)
      weighted_capacity = optional(number)
    }))
  })
}
