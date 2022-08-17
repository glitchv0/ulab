locals {
  region                 = "us-west-2" # AWS Region
  country                = "US"        # 2 letter country code, e.g. "us", "uk", "jp"
  environment            = "Dev"       # Dev, QA, or Prod
  dd_lambda_arn = ""
  max_capacity = "10"
  min_capacity = "1"
   app_names_nolb = []
  app_names_lb = [
    "ulabel"   
    ]
  #App Names (all apps)
  app_names = [
    "ulabel"    
  ]
  #Container Ports, these should correspond to the list above
  container_ports = [
    "8080"    
  ]
  #Target Groups, should match the list above
  target_group_arns = [
    "arn:aws:elasticloadbalancing:us-west-2:846287920477:targetgroup/ulabel/c856c6de1cb943d4",
     ]


  #Backend Config
  backend_region = "us-west-2"                         # AWS Region for the backend, generally should be left alone
  backend_s3_key = "${basename(get_terragrunt_dir())}" # S3 key for the backend, generally should be left alone, unless you aren't in a subfolder
}

terraform {
  source = "git::git@github.com:uLabSystems/terraform-aws-ecs-module.git//.?ref=v1.24"
}

inputs = {
  region            = local.region
  country           = local.country #iso
  environment       = local.environment
  app_names         = local.app_names
  container_ports   = local.container_ports
  target_group_arns = local.target_group_arns
  app_names_nolb    = local.app_names_nolb
  app_names_lb      = local.app_names_lb
  dd_lambda_arn     = local.dd_lambda_arn
  max_capacity      = local.max_capacity
  min_capacity      = local.min_capacity

}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.backend_region}"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket  = lower("ulab-${local.country}-${local.environment}-terraform")
    key     = "ecs/${local.backend_s3_key}/tfstate.tfstate"
    region  = "${local.backend_region}"
    encrypt = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
