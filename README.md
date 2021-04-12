# terraform-aws-asg
Template repository for terraform modules. Good for any cloud and any provider.

[![tflint](https://github.com/rhythmictech/terraform-aws-asg/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-asg/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-asg/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-asg/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-asg/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-asg/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-asg/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-asg/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-asg/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-asg/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

## Example
Here's what using the module will look like
```hcl
module "example" {
  source = "rhythmictech/terraform-mycloud-mymodule
}
```

## About
A bit about this module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.36 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.36 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_asg_tags"></a> [asg\_tags](#module\_asg\_tags) | rhythmictech/asg-tag-transform/aws | 1.0.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | rhythmictech/tags/terraform | ~> 1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group. | `number` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | What instance type to use by default | `string` | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the Auto Scaling Group | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the Auto Scaling Group | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Moniker to apply to all resources in the module | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC to use | `string` | n/a | yes |
| <a name="input_vpc_zone_identifier"></a> [vpc\_zone\_identifier](#input\_vpc\_zone\_identifier) | A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. | `list(string)` | n/a | yes |
| <a name="input_additional_iam_instance_profile_arns"></a> [additional\_iam\_instance\_profile\_arns](#input\_additional\_iam\_instance\_profile\_arns) | A set of IAM instance profile ARNs to add to the instances in adition to the default. Default allows SSM | `set(string)` | `[]` | no |
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | A list of Security Group IDs to add in addition to the default. (Default only allows access to SSM) | `list(string)` | `[]` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | A list of objects describing any additional EBS volumes to mount to the instances | <pre>set(object({<br>    delete_on_termination = optional(bool)<br>    encrypted             = optional(bool)<br>    iops                  = optional(number)<br>    kms_key_id            = optional(string)<br>    snapshot_id           = optional(string)<br>    throughput            = optional(number)<br>    volume_size           = number<br>    volume_type           = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_detailed_monitoring_enabled"></a> [detailed\_monitoring\_enabled](#input\_detailed\_monitoring\_enabled) | Whether to enable detailed monitoring on instances | `bool` | `false` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time in sconds after instance comes into service before checking health | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | (Optional) `EC2` or `ELB`. Controls how health checking is done. | `string` | `"ELB"` | no |
| <a name="input_instance_refresh"></a> [instance\_refresh](#input\_instance\_refresh) | (Optional) If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated. This resource does not wait for the instance refresh to complete. | <pre>object({<br>    strategy = string<br>    triggers = optional(set(string))<br><br>    preferences = optional(object({<br>      instance_warmup        = optional(number)<br>      min_healthy_percentage = optional(number)<br>    }))<br>  })</pre> | <pre>{<br>  "strategy": "Rolling"<br>}</pre> | no |
| <a name="input_launch_template_description"></a> [launch\_template\_description](#input\_launch\_template\_description) | A description to attach to the launch template | `string` | `null` | no |
| <a name="input_max_instance_lifetime"></a> [max\_instance\_lifetime](#input\_max\_instance\_lifetime) | (Optional) The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds. | `number` | `null` | no |
| <a name="input_mixed_instances_policy"></a> [mixed\_instances\_policy](#input\_mixed\_instances\_policy) | Object defining how to mix on-demand and spot instances of different types | <pre>object({<br>    instances_distribution = optional(object({<br>      on_demand_allocation_strategy            = optional(string)<br>      on_demand_base_capacity                  = optional(number)<br>      on_demand_percentage_above_base_capacity = optional(number)<br>      spot_allocation_strategy                 = optional(string)<br>      spot_instance_pools                      = optional(number)<br>      spot_max_price                           = optional(string)<br>    }))<br><br>    override = list(object({<br>      instance_type     = optional(string)<br>      weighted_capacity = optional(number)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_scaling_cooldown"></a> [scaling\_cooldown](#input\_scaling\_cooldown) | (Optional) The amount of time, in seconds, after a scaling activity completes before another scaling activity can start. | `number` | `null` | no |
| <a name="input_service_linked_role_arn"></a> [service\_linked\_role\_arn](#input\_service\_linked\_role\_arn) | The ARN of the service-linked role that the ASG will use to call other AWS services | `string` | `null` | no |
| <a name="input_suspended_processes"></a> [suspended\_processes](#input\_suspended\_processes) | A list of processes to suspend for the ASG. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer` | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | User-Defined tags | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | A set of aws\_alb\_target\_group ARNs, for use with Application or Network Load Balancing. | `set(string)` | `null` | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | (Default: `10m`) A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to `0` causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tags_module"></a> [tags\_module](#output\_tags\_module) | Tags Module in it's entirety |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Getting Started
This workflow has a few prerequisites which are installed through the `./bin/install-x.sh` scripts and are linked below. The install script will also work on your local machine. 

- [pre-commit](https://pre-commit.com)
- [terraform](https://terraform.io)
- [tfenv](https://github.com/tfutils/tfenv)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [tfsec](https://github.com/tfsec/tfsec)
- [tflint](https://github.com/terraform-linters/tflint)

We use `tfenv` to manage `terraform` versions, so the version is defined in the `versions.tf` and `tfenv` installs the latest compliant version.
`pre-commit` is like a package manager for scripts that integrate with git hooks. We use them to run the rest of the tools before apply. 
`terraform-docs` creates the beautiful docs (above),  `tfsec` scans for security no-nos, `tflint` scans for best practices. 
