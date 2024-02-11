# terraform-aws-minecraft-server-module
Terraform module to deploy a Minecraft server to AWS. This module is designed to be stateless and ephemeral, creating and destroying a new server should be possible without affecting the saved Minecraft worlds, this is acheived by storing the saved data in s3 externally to this module on a destroy event.

# Usage

Simple example:
```hcl
module "beamMP_server" {
  source              = "Harry-Moore-dev/terraform-aws-minecraft-server-module/aws"
  version             = "1.0.0"
  s3_save_bucket_name = "some-save-bucket"
}
```

Detailed example:
```hcl
module "beamMP_server" {
  source              = "Harry-Moore-dev/terraform-aws-minecraft-server-module/aws"
  version             = "1.0.0"
  s3_save_bucket_name = "some-save-bucket"

  region              = "eu-west-1"
  ec2_instance_type   = "t3.large"
  ec2_ebs_volume_size = 8

  ec2_spot_instance_price   = "0.01"
  ec2_spot_instance_enabled = true

  server_port               = 25565
}
```

### Loading save data

This project creates an S3 bucket in your AWS account and load the save data to a path of your choice. All save files in that path will be copied over to the server on creation so sufficient ebs volume size should be specified depending on the size of the saves loaded. On instance termination (if running) the current world will be saved to the s3 bucket for future use.

## Pre-commit config

Install dependencies for pre-commit.
```
brew install pre-commit terraform-docs tflint tfsec
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.32.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.32.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | terraform-aws-modules/ec2-instance/aws | 5.6.0 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | 5.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_default_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_iam_instance_profile.ssm_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.s3_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ssm_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.s3_write_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [null_resource.create_s3_bucket_if_doesnt_exist](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ec2_ebs_volume_size"></a> [ec2\_ebs\_volume\_size](#input\_ec2\_ebs\_volume\_size) | ec2 ebs volume size | `number` | `8` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | ec2 instance type | `string` | `"t3.small"` | no |
| <a name="input_ec2_spot_instance_enabled"></a> [ec2\_spot\_instance\_enabled](#input\_ec2\_spot\_instance\_enabled) | use ec2 spot instances (cheaper but can be terminated at any time) | `bool` | `false` | no |
| <a name="input_ec2_spot_instance_price"></a> [ec2\_spot\_instance\_price](#input\_ec2\_spot\_instance\_price) | ec2 spot instance price (adjust this for the instance type if using spot instances) | `string` | `"0.01"` | no |
| <a name="input_mc_allocated_memory"></a> [mc\_allocated\_memory](#input\_mc\_allocated\_memory) | The amount of memory allocated to the Minecraft server java runtime in MB | `number` | `1024` | no |
| <a name="input_mc_allow_flight"></a> [mc\_allow\_flight](#input\_mc\_allow\_flight) | Whether flight is allowed on the Minecraft server | `bool` | `false` | no |
| <a name="input_mc_allow_nether"></a> [mc\_allow\_nether](#input\_mc\_allow\_nether) | Whether the nether is allowed on the Minecraft server | `bool` | `true` | no |
| <a name="input_mc_custom_seed"></a> [mc\_custom\_seed](#input\_mc\_custom\_seed) | Specify a custom seed for the Minecraft server (a random seed will be used if not specified) | `string` | `""` | no |
| <a name="input_mc_difficulty"></a> [mc\_difficulty](#input\_mc\_difficulty) | The difficulty for the Minecraft server | `string` | `"easy"` | no |
| <a name="input_mc_enable_command_block"></a> [mc\_enable\_command\_block](#input\_mc\_enable\_command\_block) | Whether command blocks are enabled on the server | `bool` | `false` | no |
| <a name="input_mc_force_gamemode"></a> [mc\_force\_gamemode](#input\_mc\_force\_gamemode) | Whether to force the game mode on the Minecraft server | `bool` | `false` | no |
| <a name="input_mc_game_mode"></a> [mc\_game\_mode](#input\_mc\_game\_mode) | The game mode for the Minecraft server | `string` | `"survival"` | no |
| <a name="input_mc_generate_structures"></a> [mc\_generate\_structures](#input\_mc\_generate\_structures) | Whether structures are generated in the Minecraft server | `bool` | `true` | no |
| <a name="input_mc_hardcore"></a> [mc\_hardcore](#input\_mc\_hardcore) | Whether hardcore mode is enabled on the Minecraft server | `bool` | `false` | no |
| <a name="input_mc_level_name"></a> [mc\_level\_name](#input\_mc\_level\_name) | The name of the level for the Minecraft server | `string` | `"world"` | no |
| <a name="input_mc_level_type"></a> [mc\_level\_type](#input\_mc\_level\_type) | The type of level for the Minecraft server (: character must be double escaped with a backslash) | `string` | `"minecraft\\:normal"` | no |
| <a name="input_mc_max_players"></a> [mc\_max\_players](#input\_mc\_max\_players) | The maximum number of players for the Minecraft server | `number` | `20` | no |
| <a name="input_mc_max_world_size"></a> [mc\_max\_world\_size](#input\_mc\_max\_world\_size) | The maximum world size for the Minecraft server | `number` | `29999984` | no |
| <a name="input_mc_name"></a> [mc\_name](#input\_mc\_name) | The name of the Minecraft server | `string` | `"Minecraft Server"` | no |
| <a name="input_mc_player_idle_timeout"></a> [mc\_player\_idle\_timeout](#input\_mc\_player\_idle\_timeout) | The idle timeout for the Minecraft server (0 to disable) | `number` | `0` | no |
| <a name="input_mc_pvp"></a> [mc\_pvp](#input\_mc\_pvp) | Whether PVP is enabled on the server | `bool` | `true` | no |
| <a name="input_mc_resource_pack"></a> [mc\_resource\_pack](#input\_mc\_resource\_pack) | The resource pack for the Minecraft server | `string` | `""` | no |
| <a name="input_mc_simulation_distance"></a> [mc\_simulation\_distance](#input\_mc\_simulation\_distance) | The simulation distance for the Minecraft server | `number` | `12` | no |
| <a name="input_mc_spawn_animals"></a> [mc\_spawn\_animals](#input\_mc\_spawn\_animals) | Whether animals spawn on the Minecraft server | `bool` | `true` | no |
| <a name="input_mc_spawn_monsters"></a> [mc\_spawn\_monsters](#input\_mc\_spawn\_monsters) | Whether monsters spawn on the Minecraft server | `bool` | `true` | no |
| <a name="input_mc_spawn_npcs"></a> [mc\_spawn\_npcs](#input\_mc\_spawn\_npcs) | Whether NPCs spawn on the Minecraft server | `bool` | `true` | no |
| <a name="input_mc_view_distance"></a> [mc\_view\_distance](#input\_mc\_view\_distance) | The view distance for the Minecraft server | `number` | `32` | no |
| <a name="input_mc_whitelist_enabled"></a> [mc\_whitelist\_enabled](#input\_mc\_whitelist\_enabled) | Whether the whitelist is enabled on the Minecraft server | `bool` | `false` | no |
| <a name="input_mc_whitelisted_users"></a> [mc\_whitelisted\_users](#input\_mc\_whitelisted\_users) | A map of whitelisted users where the key is the UUID and the value is the username | `map(string)` | `{}` | no |
| <a name="input_minecraft_version"></a> [minecraft\_version](#input\_minecraft\_version) | The version of Minecraft Java edition to install, if not specified the latest version will be installed | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-west-2"` | no |
| <a name="input_s3_save_bucket_name"></a> [s3\_save\_bucket\_name](#input\_s3\_save\_bucket\_name) | The S3 bucket name to save the Minecraft server data | `string` | n/a | yes |
| <a name="input_s3_save_bucket_path"></a> [s3\_save\_bucket\_path](#input\_s3\_save\_bucket\_path) | The S3 bucket path to save the Minecraft server data | `string` | `"worlds/"` | no |
| <a name="input_s3_save_bucket_versioning"></a> [s3\_save\_bucket\_versioning](#input\_s3\_save\_bucket\_versioning) | Whether to enable versioning on the S3 bucket on first creation | `string` | `"Enabled"` | no |
| <a name="input_server_port"></a> [server\_port](#input\_server\_port) | The port the server will run on | `number` | `25565` | no |
| <a name="input_vpc_subnet_cidr_block"></a> [vpc\_subnet\_cidr\_block](#input\_vpc\_subnet\_cidr\_block) | value of the vpc cidr block for the public subnet | `string` | `"172.31.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_server_ip"></a> [server\_ip](#output\_server\_ip) | public IP of the EC2 instance used for direct connect |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
