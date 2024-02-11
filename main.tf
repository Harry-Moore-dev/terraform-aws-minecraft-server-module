locals {
  name = "Minecraft-server"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Terraform = "true"
    Project   = "Minecraft"
  }
}

resource "aws_default_vpc" "default" {}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_default_vpc.default.id
  cidr_block              = var.vpc_subnet_cidr_block
  availability_zone       = element(local.azs, 2)
  map_public_ip_on_launch = true

  tags = local.tags
}

data "aws_availability_zones" "available" {}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name = local.name

  ami                         = data.aws_ssm_parameter.latest_ami.insecure_value
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  availability_zone           = element(local.azs, 2)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true

  create_spot_instance      = var.ec2_spot_instance_enabled
  spot_price                = var.ec2_spot_instance_enabled ? var.ec2_spot_instance_price : null
  spot_type                 = var.ec2_spot_instance_enabled ? "persistent" : null
  spot_wait_for_fulfillment = var.ec2_spot_instance_enabled ? true : null

  user_data = templatefile("${path.module}/server_setup.sh.tftpl", {
    minecraft_version     = var.minecraft_version,
    save_bucket_full_path = "${var.s3_save_bucket_name}/${var.s3_save_bucket_path}",
    region                = var.region,
    server_port           = var.server_port,
    allocated_memory      = var.mc_allocated_memory,
    whitelisted_users     = jsonencode(var.mc_whitelisted_users),
    whitelist_enabled     = var.mc_whitelist_enabled,
    name                  = var.mc_name,
    pvp                   = var.mc_pvp,
    custom_seed           = var.mc_custom_seed,
    game_mode             = var.mc_game_mode,
    enable_command_block  = var.mc_enable_command_block,
    level_name            = var.mc_level_name,
    level_type            = var.mc_level_type,
    generate_structures   = var.mc_generate_structures,
    difficulty            = var.mc_difficulty,
    max_players           = var.mc_max_players,
    allow_flight          = var.mc_allow_flight,
    view_distance         = var.mc_view_distance,
    simulation_distance   = var.mc_simulation_distance,
    allow_nether          = var.mc_allow_nether,
    resource_pack         = var.mc_resource_pack,
    player_idle_timeout   = var.mc_player_idle_timeout,
    force_gamemode        = var.mc_force_gamemode,
    hardcore              = var.mc_hardcore,
    spawn_npcs            = var.mc_spawn_npcs,
    spawn_animals         = var.mc_spawn_animals,
    spawn_monsters        = var.mc_spawn_monsters,
    max_world_size        = var.mc_max_world_size
  })

  root_block_device = [
    {
      volume_size = var.ec2_ebs_volume_size
      volume_type = "gp3"
    }
  ]

  tags = local.tags

  iam_instance_profile = "ssm-instance-profile"
}

data "aws_ssm_parameter" "latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-${var.ec2_architecture}"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_ssm_document" "save_world_on_shutdown" {
  name          = "save_world_on_shutdown"
  document_type = "Command"
  content       = <<-EOT
{
  "schemaVersion": "2.2",
  "description": "Save the world on shutdown",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "save_world",
      "inputs": {
        "runCommand": [
          "systemctl stop minecraft.service",
          "aws s3 cp /opt/minecraft/server/${var.mc_level_name} s3://${var.s3_save_bucket_name}/${var.s3_save_bucket_path} --recursive --region ${var.region}"
        ]
      }
    }
  ]
}
EOT
}

resource "aws_cloudwatch_event_rule" "save_world_on_shutdown" {
  name        = "save_world_on_shutdown"
  description = "Save the world on shutdown"
  event_pattern = jsonencode({
    source = ["aws.ec2"],
    detail = {
      "state" : ["shutting-down"],
      "instance-id" : [module.ec2.id]
    },
    detail_type = ["EC2 Instance State-change Notification"]
  })
}

resource "aws_cloudwatch_event_target" "save_world_on_shutdown" {
  rule      = aws_cloudwatch_event_rule.save_world_on_shutdown.name
  target_id = "save_world_on_shutdown"
  arn       = aws_ssm_document.save_world_on_shutdown.arn
}

# Note this will create an s3 bucket on first deployment that is not managed inside of state, this will need to be destroyed manually if required or the name is changed
resource "null_resource" "create_s3_bucket_if_doesnt_exist" {
  provisioner "local-exec" {
    command = <<-EOT
      if ! aws s3api head-bucket --bucket ${var.s3_save_bucket_name} --region ${var.region} 2>/dev/null; then
        aws s3api create-bucket --bucket ${var.s3_save_bucket_name} --acl private --region ${var.region} --create-bucket-configuration LocationConstraint=${var.region}
        aws s3api put-bucket-versioning --bucket ${var.s3_save_bucket_name} --versioning-configuration Status=${var.s3_save_bucket_versioning} --region ${var.region}
      fi
    EOT
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_write_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

resource "aws_iam_policy" "s3_write_policy" {
  name        = "s3-read-policy"
  description = "Policy for S3 read access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3ReadAccess"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = ["arn:aws:s3:::${var.s3_save_bucket_name}/*"]
      },
      {
        Sid      = "S3ListBucketAccess"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::*"]
      }
    ]
  })
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = local.name
  description = "BeamMP server security group"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = var.server_port
      to_port     = var.server_port
      protocol    = "tcp"
      description = "Allow ingress on port ${var.server_port} for TCP"
    },
    {
      from_port   = var.server_port
      to_port     = var.server_port
      protocol    = "udp"
      description = "Allow ingress on port ${var.server_port} for UDP"
    }
  ]
  tags = local.tags
}
