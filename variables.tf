variable "unipipe_git_remote" {
  type        = string
  description = "Git repo URL. Use a deploy key (GitHub) or similar to setup an automation user SSH key for unipipe."
}

variable "project_id" {
  type        = string
  description = "The project ID to deploy resource into"
}

variable "cloudrun_service_name" {
  type        = string
  description = "The CloudRun service name"
  default     = "unipipe-demo"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  type        = string
  description = "The Region to deploy resource into"
  default     = "europe-west3"
}

variable "unipipe_version" {
  type        = string
  description = "Unipipe version, see https://github.com/meshcloud/unipipe-service-broker/releases"
  default     = "latest"
}

variable "unipipe_basic_auth_username" {
  type        = string
  description = "OSB API basic auth username"
  default     = "user"
}

variable "unipipe_git_branch" {
  type        = string
  description = "git branch name"
  default     = "main"
}
