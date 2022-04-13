terraform {
  # Removing the backend will output the terraform state in the local filesystem
  # See https://www.terraform.io/language/settings/backends for more details
  #
  # Remove/comment the backend block below if you are only testing the module.
  # Please be aware that you cannot destroy the created resources via terraform if you lose the state file.
  backend "gcs" {
    bucket = "..."
    prefix = "unipipe-demo"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.22.0"
    }
  }
}

provider "github" {
  owner = "..." # The GitHub organization the instance repostiory lives in.
}

# GitHub repository
resource "github_repository" "instance_repository" {
  name = "unipipe-demo"

  visibility  = "private"
  description = "This is the git instance repository used by UniPipe Service Broker."
}

# UniPipe container on GCP
module "unipipe" {
  source     = "git@github.com:meshcloud/terraform-gcp-unipipe.git?ref=c758f8f27b0187da467fb8a9fd1dd583935036af"
  project_id = local.project_id

  unipipe_git_remote = github_repository.instance_repository.ssh_clone_url
}

# Grant the container access to the GitHub repository.
resource "github_repository_deploy_key" "unipipe-ssh-key" {
  title      = "unipipe-service-broker-deploy-key"
  repository = github_repository.instance_repository.name
  key        = module.unipipe.unipipe_git_ssh_key
  read_only  = "false"
}
