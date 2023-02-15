# Terraform Example Deployment

# Resources Includes
- Azure

# Azure Credentials

Follow this guide to get Azure credentials: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret

# Deployment Steps

1. Clone this repo
2. Copy `terraform.tfvars.dist` to `terraform.tfvars` and update with your information
3. Run `terraform init` and `terraform plan`
4. Once satisfied with what it will deploy, run `terraform apply`

# Teardown

1. In the directory where you deployed, run `terraform destroy`

