################################
### CONFIGURE REQUIRED PATHS ###
################################

locals {
  yaml_config_path     = "../infra-config.yml"         # Required settings
  root                 = ".."                          # Path to root of repo
  secrets_folder       = "../.secrets"                 # Default secrets location
  aws_credentials_file = "../.secrets/aws-credentials" # AWS Credentials
}

############################################
### STANDARD ENVIRONMENT DEFINITION      ###
### NO NEED TO MODIFY REMAINDER OF FILE  ###
############################################

data "local_file" "config_yml" { filename = local.yaml_config_path }
locals {
  config            = yamldecode(data.local_file.config_yml.content)
  project_shortname = local.config["project_shortname"]
  aws_region        = local.config["aws_region"]
  resource_tags     = local.config["resource_tags"]
  name_prefix       = "${local.project_shortname}-"
}

output "env_summary" { value = module.env.summary }
module "env" {
  source               = "git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/environment?ref=main"
  name_prefix          = local.name_prefix
  aws_region           = local.aws_region
  aws_credentials_file = local.aws_credentials_file
  resource_tags        = local.resource_tags

  # For documentation and additional options, see:
  # https://infra.dataops.tk/catalog/aws/environment
}

terraform {
  required_providers {
    aws = "~> 3.0"
  }
}

provider "aws" {
  region                  = local.aws_region
  shared_credentials_file = local.aws_credentials_file
  profile                 = "default"
}
