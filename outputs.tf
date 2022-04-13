output "url" {
  value       = google_cloud_run_service.default[*].status[*].url
  description = "UniPipe API URL. If you want access to the catalog page, you can add /v2/catalog at the end of the url."
  depends_on = [
    google_cloud_run_service.default
  ]
}
output "unipipe_basic_auth_username" {
  value       = var.unipipe_basic_auth_username
  description = "OSB API basic auth username"
}
output "unipipe_basic_auth_password" {
  value       = random_password.unipipe_basic_auth_password.result
  sensitive   = true
  description = "OSB API basic auth password"
}
output "unipipe_git_ssh_key" {
  value       = tls_private_key.unipipe_git_ssh_key.public_key_openssh
  description = "UniPipe will use this key to access the git repository. You have to give read+write access on the target repository for this key."
}
output "info" {
  value = "UniPipe is starting now. This may take a couple of minutes."
}
