
variable "name" {
  description = "Moniker to apply to all resources in the module"
  type        = string
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

variable "launch_configuration" {
  default     = null
  description = "(Optional) The name of the launch configuration to use. (`launch_template` is preferred)"
  type        = string
}

variable "launch_template" {
  default     = null
  description = "(Optional) Nested argument with Launch template specification to use to launch instances."
  type        = map(string)
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

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside."
  type        = list(string)
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

    launch_template = object({
      launch_template_specification = object({
        launch_template_id   = optional(string)
        launch_template_name = optional(string)
        version              = optional(string)
      })

      override = list(object({
        instance_type     = optional(string)
        weighted_capacity = optional(number)

        launch_template_specification = optional(object({
          launch_template_id   = optional(string)
          launch_template_name = optional(string)
          version              = optional(string)
        }))
      }))
    })
  })
}
