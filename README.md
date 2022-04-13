# terraform-gcp-unipipe

UniPipe Service Broker is an open source project for offering services. GCP is a proprietary public cloud platform provided by Google.

This terraform module provides a setup UniPipe Service Broker on CloudRun.

This setup will store the private key in your terrraform state and is thus not recommended for production use cases.

## Prerequisites

- [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Valid GCloud credentials to execute terraform `gcloud auth login` and `gcloud auth configure-docker`
- Permissions `resourcemanager.projects.setIamPolicy` and `resourcemanager.projects.getIamPolicy` on the GCloud Project. Therefore `roles/editor` permissions are not sufficient.
- [docker installed](https://www.docker.com/get-started/) This module uses docker pull/push commands for mirroring the unipipe-service-broker images.
