# AI-Assisted Development Prompts - TechFlow Challenge

This document outlines the key prompts used to accelerate the development of the infrastructure, application, and CI/CD pipelines for the TechFlow DevSecOps challenge.

## 1. CI/CD Pipeline: Optimized Application Deployment
**File:** `techflow-azure-devsecops-challenge/.github/workflows/deploy-app.yml`

**Prompt:**
> "Create a GitHub Actions workflow named 'Deploy Application' with the following DevSecOps requirements:
> 1. **Triggers**: Enable `workflow_dispatch` for manual runs and `pull_request` for 'develop' and 'main' branches, but only when changes occur in the 'app/**' directory or the workflow file itself.
> 2. **Build & Scan Job**: 
>    - Build a Docker image tagged with the GitHub SHA.
>    - Integrate **Trivy** to scan the image for CRITICAL and HIGH vulnerabilities, stopping the pipeline if any are found.
>    - Authenticate with Azure and push the image to an ACR using both 'latest' and SHA tags.
> 3. **Deploy Job**:
>    - Use `az containerapp update` to deploy the new image to an existing Azure Container App.
>    - Retrieve the application's FQDN using `az containerapp show`.
>    - Use `GITHUB_STEP_SUMMARY` to display a success message and the clickable URL of the deployed application.
> 4. **Best Practices**: Implement concurrency control to cancel in-progress runs and use OIDC/Service Principal for secure Azure authentication."

## 2. CI/CD Pipeline: Infrastructure as Code (IaC) Plan & Apply
**File:** `techflow-azure-devsecops-challenge/.github/workflows/deploy-iac-plan-apply.yml`

**Prompt:**
> "Develop a GitHub Actions workflow named 'Terraform Plan & Apply' to automate infrastructure deployment on Azure. The workflow should:
> 1. **Triggers**: Execute on every push to 'feature/infra-setup', 'develop', and 'main' branches.
> 2. **Security & Compliance**: Integrate **Checkov** to perform a static analysis (IaC scan) of the Terraform files, ensuring security best practices are audited before deployment.
> 3. **Environment Configuration**: Securely handle Azure credentials (ARM_CLIENT_ID, SECRET, SUBSCRIPTION, TENANT, and ACCESS_KEY) using GitHub Secrets and OIDC permissions.
> 4. **Terraform Lifecycle**:
>    - Initialize Terraform using a remote Azure backend with dynamic configuration for the resource group and storage account.
>    - Perform a format check (`fmt -check`) to maintain code quality.
>    - Generate an execution plan (`plan`) specifically using the 'develop.tfvars' variable file.
>    - Execute `terraform apply` with auto-approval to ensure the infrastructure is kept in sync with the repository.
> 5. **Reliability**: Use concurrency management to prevent state locks and cancel redundant workflow runs."

## 3. CI/CD Pipeline: Infrastructure Destruction (Safety Gate)
**File:** `techflow-azure-devsecops-challenge/.github/workflows/deploy-iac-plan-destroy.yml`

**Prompt:**
> "Create a GitHub Actions workflow named 'Terraform Plan & Destroy' to safely manage the decommissioning of Azure resources. The requirements are:
> 1. **Manual Safety Gate**: Use `workflow_dispatch` with a mandatory input called 'confirmation'. The job should only proceed if the user explicitly types 'destroy'.
> 2. **Environment & Security**: Set the execution environment to 'develop' and map Azure SPN credentials (Client ID, Secret, Tenant, and Subscription) and the Terraform State access key from GitHub Secrets.
> 3. **Terraform Lifecycle**:
>    - Initialize the backend using a remote Azure storage configuration.
>    - Generate a destruction plan (`terraform plan -destroy`) using the 'develop.tfvars' file and save it to an output file.
>    - Display the plan details using `terraform show` so the operator can review exactly what will be deleted.
>    - Execute the destruction using `terraform apply` with the generated plan and auto-approval.
> 4. **Concurrency**: Ensure that only one destruction process can run at a time to maintain state integrity."

## 4. Application Development: Flask API with Secret Integration
**File:** `techflow-azure-devsecops-challenge/app/app.py`

**Prompt:**
> "Develop a lightweight web API using Python and Flask that serves as the main application for the TechFlow challenge. The script must:
> 1. **Endpoint**: Define a root route ('/') that returns a JSON response.
> 2. **Secret Retrieval**: Access an environment variable named 'MY_SECRET' using the `os` module. This variable is expected to be injected via Azure Key Vault through Managed Identity at runtime.
> 3. **JSON Structure**: The response must include a greeting message ('Hola Mundo desde TechFlow!'), the retrieved secret value, a status indicator, and a custom field confirming 'Managed Identity Active'.
> 4. **Networking**: Configure the application to listen on host '0.0.0.0' and port 8000 to ensure compatibility with Docker and Azure Container Apps ingress.
> 5. **Robustness**: Provide a default fallback message if the secret is not found in the environment."

## 5. Containerization: Secure & Optimized Dockerfile
**File:** `techflow-azure-devsecops-challenge/app/Dockerfile`

**Prompt:**
> "Create a production-grade Dockerfile for a Python Flask application following DevSecOps security best practices:
> 1. **Base Image**: Use a stable and lightweight version of Python (3.11-slim) to minimize the attack surface and image size.
> 2. **Python Environment**: Set environment variables to disable bytecode generation (.pyc) and ensure unbuffered logging for real-time monitoring.
> 3. **Dependency Management**: Copy only the 'requirements.txt' first to leverage Docker layer caching. Use 'pip' with the '--no-cache-dir' flag to keep the image slim.
> 4. **Security & Least Privilege**: Create a non-privileged system user named 'appuser', change ownership of the application directory, and ensure the container runs as this user instead of root.
> 5. **Source Code**: Copy the application source code after dependency installation to optimize build times.
> 6. **Production Server**: Expose port 8000 and configure Gunicorn as the entry point, binding it to 0.0.0.0 for compatibility with Azure Container Apps."

## 6. Dependency Management: Python Requirements
**File:** `techflow-azure-devsecops-challenge/app/requirements.txt`

**Prompt:**
> "Generate a 'requirements.txt' file for a production-ready Flask application to be deployed on Azure Container Apps. The requirements must include:
> 1. **Flask**: Specify version 3.1.2 to ensure the use of current security features and framework capabilities.
> 2. **Gunicorn**: Include version 23.0.0 as the production-grade WSGI HTTP server required for handling requests in a containerized environment.
> 3. **Version Pinning**: Use exact version pinning (==) to guarantee environment consistency across local development, security scanning (Trivy), and production deployment, preventing 'breaking changes' during automated builds."

## 7. Infrastructure: Azure Container Apps Environment
**File:** `techflow-azure-devsecops-challenge/components/compute/container_app_env.tf`

**Prompt:**
> "Create a Terraform resource for an Azure Container Apps Environment (`azurerm_container_app_environment`). The configuration must:
> 1. **Naming Convention**: Use a standardized naming pattern 'cae-${var.project_name}-${var.environment}' to maintain consistency across deployment stages.
> 2. **Regional Placement**: Dynamically assign the location and resource group based on the variables provided by the parent module.
> 3. **Modular Design**: Ensure the resource is isolated within the 'compute' component to follow a clean, modular infrastructure-as-code architecture as required for the TechFlow challenge."

## 8. Infrastructure: Scheduled Maintenance Job (Cron Job)
**File:** `techflow-azure-devsecops-challenge/components/compute/cron_job.tf`

**Prompt:**
> "Write a Terraform resource for an Azure Container App Job (`azurerm_container_app_job`) to handle scheduled tasks. The configuration must include:
> 1. **Identification**: Name the job 'job-${var.project_name}-cleanup' and link it to the existing Container App Environment.
> 2. **Identity**: Configure a 'UserAssigned' Managed Identity using the identity ID provided by the security module.
> 3. **Schedule**: Implement a `schedule_trigger_config` with a cron expression to run daily at midnight ('0 0 * * *').
> 4. **Container Template**:
>    - Use the 'alpine:latest' image for a minimal footprint.
>    - Define a shell command that prints 'Job ejecutado con éxito' as required by the technical challenge.
>    - Set resource limits to 0.25 CPU and 0.5Gi memory.
> 5. **Reliability**: Configure a replica timeout of 300 seconds and a single retry limit."

## 9. Infrastructure: Main Azure Container App (API)
**File:** `techflow-azure-devsecops-challenge/components/compute/main_app.tf`

**Prompt:**
> "Create a Terraform resource for an Azure Container App that acts as the primary API for the TechFlow challenge. The configuration must implement the following DevSecOps requirements:
> 1. **Authentication & Registry**: Use a 'UserAssigned' Managed Identity for both the app's identity and as the credential provider to pull images from the Azure Container Registry (ACR).
> 2. **Secret Integration**: Map a secret from Azure Key Vault (referenced via its Resource ID) to an internal secret named 'my-secret-val', then expose it to the main container as an environment variable named 'MY_SECRET'.
> 3. **Init Container**: Include a mandatory 'init-db-migration' container using a lightweight Alpine image. It must execute a shell command to simulate a 5-second database migration before the application starts.
> 4. **Main Container**: Define the 'api-gateway' container using the image from the project's ACR, configured with 0.25 CPU and 0.5Gi memory.
> 5. **Networking & Ingress**: Enable external HTTP ingress on port 8000. Ensure security by disabling insecure connections and routing 100% of traffic to the latest single revision.
> 6. **Revision Management**: Set the revision mode to 'Single' to maintain a stable environment."

## 10. Infrastructure: Compute Module Variable Definitions
**File:** `techflow-azure-devsecops-challenge/components/compute/variables.tf`

**Prompt:**
> "Define the input variables for the Terraform 'compute' module to support the deployment of Azure Container Apps and Jobs. The requirements include:
> 1. **Core Infrastructure**: Declare variables for 'resource_group_name', 'location', 'project_name', and 'environment' to enable dynamic resource naming and placement.
> 2. **Security Integration**: Define a variable for the User Assigned Managed Identity Resource ID, ensuring the container app can authenticate securely.
> 3. **Secret Management**: Include a variable for the Versionless ID of the Key Vault secret to allow for automatic secret rotation and secure injection.
> 4. **Registry Linking**: Declare the 'acr_login_server' variable to provide the FQDN required for the container app to pull images from the private registry.
> 5. **Documentation**: Ensure each variable includes a technical description to meet the project's standards for code maintainability and clarity."

## 11. Infrastructure: Azure Container Registry (ACR) & Role-Based Access Control
**File:** `techflow-azure-devsecops-challenge/components/registry/acr.tf`

**Prompt:**
> "Develop a Terraform configuration to provision an Azure Container Registry (ACR) and its corresponding access controls. The solution must include:
> 1. **Registry Deployment**: Create an ACR named using a combination of the project name and a unique suffix. Set the SKU to 'Basic' for cost optimization during the technical assessment.
> 2. **Security & Identity**: Disable the legacy 'admin_enabled' flag to enforce modern identity-based authentication.
> 3. **Policy Compliance (Checkov)**: Include specific 'checkov:skip' annotations for policies that cannot be met due to the Basic SKU limitations (e.g., Geo-replication, Vulnerability Scanning, and Dedicated Data Endpoints), providing clear justifications for each.
> 4. **Role Assignment**: Implement an `azurerm_role_assignment` to grant the 'AcrPull' role to the project's Managed Identity. This ensures that the Azure Container App can securely authenticate and pull images without hardcoded credentials."

## 12. Infrastructure: Registry Module Outputs
**File:** `techflow-azure-devsecops-challenge/components/registry/outputs.tf`

**Prompt:**
> "Define the Terraform outputs for the 'registry' module to facilitate integration with other components and the CI/CD pipeline. The configuration must:
> 1. **Resource Exposure**: Export the `login_server` attribute of the Azure Container Registry.
> 2. **Technical Documentation**: Include a detailed description explaining that this FQDN is essential for Docker authentication, image tagging, and the `docker push` operations within the GitHub Actions deployment workflow.
> 3. **Interoperability**: Ensure the output value is structured to be consumed by the root module and subsequently passed to the compute module for container image configuration."

## 13. Infrastructure: Registry Module Variable Definitions
**File:** `techflow-azure-devsecops-challenge/components/registry/variables.tf`

**Prompt:**
> "Define the input variables for the Terraform 'registry' module to support the creation of a secure Azure Container Registry (ACR). The requirements include:
> 1. **Resource Context**: Declare variables for 'resource_group_name', 'location', and 'project_name' to ensure proper placement and naming.
> 2. **Global Uniqueness**: Include a 'suffix' variable with a default empty value to handle Azure's requirement for globally unique ACR names.
> 3. **Environment Traceability**: Declare an 'environment' variable to facilitate resource tagging and lifecycle management across different deployment stages.
> 4. **Access Control Integration**: Define the 'identity_principal_id' variable. This is critical for receiving the Object ID of the Managed Identity from the security module to establish the 'AcrPull' role assignment.
> 5. **Documentation**: Provide clear technical descriptions for each variable to maintain the project's high standards for modularity and clarity."

## 14. Infrastructure: Security Module (Managed Identity & Key Vault)
**File:** `techflow-azure-devsecops-challenge/components/security/azure_key_vault.tf`

**Prompt:**
> "Develop a Terraform security module that implements 'Zero Trust' and 'Least Privilege' principles for the TechFlow challenge. The configuration must:
> 1. **Identity Management**: Provision a `azurerm_user_assigned_identity` named 'id-${var.project_name}-${var.environment}' for the application to use.
> 2. **Secure Secret Storage**: Create an Azure Key Vault with a globally unique name. Enable `purge_protection_enabled` and set `soft_delete_retention_days` to 7 to prevent accidental data loss.
> 3. **Policy Compliance (Checkov)**: Include 'checkov:skip' annotations for network and firewall policies that are simplified for this technical evaluation, providing clear justifications for each.
> 4. **Access Policies**: 
>    - Grant the current deployment principal (CI/CD) full secret management permissions (Set, Delete, Purge, etc.).
>    - Grant the Managed Identity ONLY 'Get' permissions to ensure it can read secrets but not modify them.
> 5. **Secret Creation**: Provision a secret named 'MY-SECRET' with a sample value, including a `content_type` and an `expiration_date` to demonstrate secret lifecycle management best practices."

## 15. Infrastructure: Security Module Outputs
**File:** `techflow-azure-devsecops-challenge/components/security/outputs.tf`

**Prompt:**
> "Define the Terraform outputs for the 'security' module to enable seamless resource referencing and cross-module communication. The outputs must include:
> 1. **Identity Resource ID**: Export the full ID of the User Assigned Managed Identity. Add a technical description explaining its use for Container App authentication.
> 2. **Versionless Secret ID**: Export the `versionless_id` of the Key Vault secret. Explicitly mention in the description that this is a best practice to ensure the application always retrieves the latest enabled secret version without manual intervention.
> 3. **Principal ID**: Export the `principal_id` (Object ID) of the Managed Identity. Note its necessity for establishing RBAC role assignments (like AcrPull) in the registry module.
> 4. **Quality Standards**: Ensure each output has a clear, descriptive comment to facilitate maintainability and fulfill the challenge's documentation requirements."

## 16. Infrastructure: Security Module Variable Definitions
**File:** `techflow-azure-devsecops-challenge/components/security/variables.tf`

**Prompt:**
> "Define the input variables for the Terraform 'security' module to support the creation of identity and secret management resources. The requirements include:
> 1. **Administrative Scope**: Declare 'resource_group_name' and 'location' variables to ensure the security stack is deployed within the correct Azure context.
> 2. **Global Uniqueness**: Define a 'suffix' variable with a default empty value to satisfy Azure's strict global naming requirements for Key Vault instances.
> 3. **Contextual Naming**: Include 'project_name' and 'environment' variables to allow the module to programmatically generate consistent names for the Managed Identity and Key Vault.
> 4. **Best Practices**: Provide detailed descriptions for each variable to ensure the infrastructure is well-documented and easy to maintain for future team members or automated systems."

## 17. Infrastructure: Environment Variable Values (tfvars)
**File:** `techflow-azure-devsecops-challenge/develop.tfvars`

**Prompt:**
> "Create a Terraform variable definitions file (`.tfvars`) specifically for the 'develop' environment. The file must:
> 1. **Project Identification**: Set the `project_name` to 'techflow' and the `environment` to 'develop' to ensure consistent resource naming across the stack.
> 2. **Regional Deployment**: Define the Azure region as 'eastus' for all provisioned resources.
> 3. **Uniqueness**: Assign a specific alphanumeric `suffix` (e.g., '29413') to prevent naming collisions for globally unique Azure services like Key Vault and ACR.
> 4. **Resource Group Mapping**: Explicitly define the `resource_group_name` as 'rg-techflow-develop' to align with the pre-existing or planned Azure infrastructure hierarchy.
> 5. **Structure**: Maintain a clean, commented format that clearly separates mandatory infrastructure settings."

## 18. Infrastructure: Root Module Orchestration
**File:** `techflow-azure-devsecops-challenge/main.tf`

**Prompt:**
> "Design the main Terraform entry point (`main.tf`) to orchestrate a modular infrastructure on Azure for the TechFlow challenge. The configuration must:
> 1. **Resource Group**: Provision a primary `azurerm_resource_group` using a dynamic naming convention based on the project name and environment.
> 2. **Modular Architecture**: Integrate three distinct local modules ('security', 'registry', and 'compute') to promote separation of concerns.
> 3. **Dependency Injection**: 
>    - Ensure the 'security' module is processed to provide Managed Identity and Key Vault details.
>    - Pass the security outputs (Identity ID and Principal ID) to both the 'registry' and 'compute' modules to enable RBAC and secret access.
>    - Pass the 'registry' output (Login Server) to the 'compute' module to allow image pulling.
> 4. **Resource Propagation**: Efficiently forward core variables such as `location`, `project_name`, and `suffix` across all modules to ensure architectural consistency.
> 5. **Lifecycle Management**: Coordinate the resource hierarchy so that the Resource Group is the parent container for all provisioned components."

## 19. Infrastructure: Terraform Providers & Backend Configuration
**File:** `techflow-azure-devsecops-challenge/providers.tf`

**Prompt:**
> "Configure the Terraform provider and backend settings for a secure Azure deployment. The configuration must include:
> 1. **Version Requirements**: Restrict the Terraform engine to version '>= 1.11.0' and pin the 'azurerm' provider to '~> 4.15' and 'azuread' to '~> 3.1' to ensure compatibility and stability.
> 2. **Remote Backend**: Define an empty 'azurerm' backend block to allow for dynamic configuration through the CI/CD pipeline (backend-config).
> 3. **Provider Customization**: 
>    - Configure the `azurerm` provider with `resource_provider_registrations` set to 'core'.
>    - Customize 'features' for Key Vault to allow `purge_soft_delete_on_destroy`, facilitating cleanup during the technical challenge.
>    - Set the resource group behavior to allow deletion even if it contains resources to streamline environment teardown.
> 4. **Authentication**: Explicitly disable `use_msi` and `use_cli` within the provider block to ensure the workflow relies solely on the Service Principal credentials provided via environment variables."

## 20. Infrastructure: Root Module Variable Definitions
**File:** `techflow-azure-devsecops-challenge/variables.tf`

**Prompt:**
> "Define the global input variables for the root Terraform module to standardize resource provisioning across the entire Azure environment. The requirements include:
> 1. **Global Context**: Declare 'resource_group_name', 'location', and 'project_name' as the primary variables to control the deployment scope and resource identity.
> 2. **Uniqueness Strategy**: Include a 'suffix' variable with a default empty value, specifically designed to be appended to resource names that require global uniqueness (ACR and Key Vault) within the Azure ecosystem.
> 3. **Environment Management**: Define an 'environment' variable to differentiate between deployment stages (e.g., develop, staging, production) and to facilitate resource tagging.
> 4. **Standards & Documentation**: Ensure every variable includes a clear, technical description that explains its role in the naming convention and infrastructure organization, adhering to the challenge's best practices for maintainable code."