variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "ec2_instance_type" {
  type        = string
  description = "ec2 instance type"
  default     = "t3.large"
}

variable "ec2_architecture" {
  type        = string
  description = "ec2 instance architecture"
  default     = "x86_64"
  validation {
    condition     = can(regex("x86_64|arm64", var.ec2_architecture))
    error_message = "ec2_architecture must be either 'x86_64' or 'arm64'"
  }
}

variable "ec2_ebs_volume_size" {
  type        = number
  description = "ec2 ebs volume size"
  default     = 15
}

variable "ec2_spot_instance_price" {
  type        = string
  description = "ec2 spot instance price (adjust this for the instance type if using spot instances)"
  default     = "0.01"
}

variable "ec2_spot_instance_enabled" {
  type        = bool
  description = "use ec2 spot instances (cheaper but can be terminated at any time)"
  default     = false
}

variable "vpc_subnet_cidr_block" {
  type        = string
  description = "value of the vpc cidr block for the public subnet"
  default     = "172.31.0.0/16"
}

variable "server_port" {
  type        = number
  description = "The port the server will run on"
  default     = 25565
}

variable "s3_save_bucket_name" {
  type        = string
  description = "The S3 bucket name to save the Minecraft server data"
}

variable "s3_save_bucket_path" {
  type        = string
  description = "The S3 bucket path to save the Minecraft server data"
  default     = "world"
}

variable "s3_save_bucket_versioning" {
  type        = string
  description = "Whether to enable versioning on the S3 bucket on first creation"
  default     = "Enabled"
  validation {
    condition     = can(regex("Enabled|Disabled", var.s3_save_bucket_versioning))
    error_message = "s3_save_bucket_versioning must be either 'Enabled' or 'Disabled'"
  }
}

variable "minecraft_version" {
  type        = string
  description = "The version of Minecraft Java edition to install, if not specified the latest version will be installed"
  default     = ""
}

variable "mc_allocated_memory" {
  type        = number
  description = "The amount of memory allocated to the Minecraft server java runtime in MB"
  default     = 1024
}

variable "mc_whitelisted_users" {
  type = list(object({
    uuid = string
    name = string
  }))
  description = "A map of whitelisted users where the key is the UUID and the value is the username"
  default     = []
}

variable "mc_whitelist_enabled" {
  type        = bool
  description = "Whether the whitelist is enabled on the Minecraft server"
  default     = false
}

variable "mc_name" {
  type        = string
  description = "The name of the Minecraft server"
  default     = "Minecraft Server"
}

variable "mc_pvp" {
  type        = bool
  description = "Whether PVP is enabled on the server"
  default     = true
}

variable "mc_custom_seed" {
  type        = string
  description = "Specify a custom seed for the Minecraft server (a random seed will be used if not specified)"
  default     = ""
}

variable "mc_game_mode" {
  type        = string
  description = "The game mode for the Minecraft server"
  default     = "survival"
}

variable "mc_enable_command_block" {
  type        = bool
  description = "Whether command blocks are enabled on the server"
  default     = false
}

variable "mc_level_name" {
  type        = string
  description = "The name of the level for the Minecraft server"
  default     = "world"
}

variable "mc_level_type" {
  type        = string
  description = "The type of level for the Minecraft server (: character must be double escaped with a backslash)"
  default     = "minecraft\\:normal"
}

variable "mc_generate_structures" {
  type        = bool
  description = "Whether structures are generated in the Minecraft server"
  default     = true
}

variable "mc_difficulty" {
  type        = string
  description = "The difficulty for the Minecraft server"
  default     = "easy"
}

variable "mc_max_players" {
  type        = number
  description = "The maximum number of players for the Minecraft server"
  default     = 20
}

variable "mc_allow_flight" {
  type        = bool
  description = "Whether flight is allowed on the Minecraft server"
  default     = false
}

variable "mc_view_distance" {
  type        = number
  description = "The view distance for the Minecraft server"
  default     = 32
}

variable "mc_simulation_distance" {
  type        = number
  description = "The simulation distance for the Minecraft server"
  default     = 12
}

variable "mc_allow_nether" {
  type        = bool
  description = "Whether the nether is allowed on the Minecraft server"
  default     = true
}

variable "mc_resource_pack" {
  type        = string
  description = "The resource pack for the Minecraft server"
  default     = ""
}

variable "mc_player_idle_timeout" {
  type        = number
  description = "The idle timeout for the Minecraft server (0 to disable)"
  default     = 0
}

variable "mc_force_gamemode" {
  type        = bool
  description = "Whether to force the game mode on the Minecraft server"
  default     = false
}

variable "mc_hardcore" {
  type        = bool
  description = "Whether hardcore mode is enabled on the Minecraft server"
  default     = false
}

variable "mc_spawn_npcs" {
  type        = bool
  description = "Whether NPCs spawn on the Minecraft server"
  default     = true
}

variable "mc_spawn_animals" {
  type        = bool
  description = "Whether animals spawn on the Minecraft server"
  default     = true
}

variable "mc_spawn_monsters" {
  type        = bool
  description = "Whether monsters spawn on the Minecraft server"
  default     = true
}

variable "mc_max_world_size" {
  type        = number
  description = "The maximum world size for the Minecraft server"
  default     = 29999984
}
