# AI-Assisted Development Prompts - TechFlow Challenge

This document outlines the key prompts used to accelerate the development of the infrastructure, application, and CI/CD pipelines for the TechFlow DevSecOps challenge.

## 1. CI/CD Pipeline: Application Deployment
**File:** `techflow-azure-devsecops-challenge/.github/workflows/deploy-app.yml`

**Prompt:**
> "Create a GitHub Actions workflow named 'Deploy Application' that triggers on pushes to 'feature/infra-setup' and 'develop' branches. The workflow must include two main jobs: 
> 1. **build-and-scan**: Build a Docker image for a Flask API located in the './app' directory, tag it with the GitHub SHA, and run a security scan using Trivy. The scan should fail the pipeline if CRITICAL or HIGH vulnerabilities are found. After a successful scan, log into Azure ACR using stored secrets and push the image with both 'latest' and SHA tags.
> 2. **deploy-to-azure**: This job should depend on 'build-and-scan'. It must log into Azure and use the Azure CLI (`az containerapp update`) to update an existing Azure Container App with the newly pushed 'latest' image from the ACR. Ensure all sensitive values like ACR names and resource groups are handled via GitHub Secrets."

## 2. CI/CD Pipeline: Infrastructure as Code (IaC)
**File:** `techflow-azure-devsecops-challenge/.github/workflows/deploy-iac-plan-apply.yml`

**Prompt:**
> "Design a GitHub Actions workflow for Terraform named 'Terraform Plan & Apply' that triggers on pushes to 'feature/infra-setup' and 'develop' branches. The workflow must:
> 1. **Security Scan**: Integrate Checkov to perform an IaC scan on the Terraform directory. Set 'soft_fail' to true to allow the pipeline to continue while documenting security findings.
> 2. **Environment Setup**: Use the latest Ubuntu runner and configure Azure credentials (Client ID, Secret, Subscription, and Tenant) using environment variables linked to GitHub Secrets.
> 3. **Terraform Lifecycle**: 
>    - Initialize Terraform using a remote Azure backend, passing configuration for the resource group, storage account, and container via secrets.
>    - Perform a format check (`terraform fmt`).
>    - Generate an execution plan (`terraform plan`) using a variables file named 'develop.tfvars'.
>    - Automatically apply the plan (`terraform apply`) only if the push is to the specified branches. 
> Ensure the workflow is modular and secure, following DevSecOps best practices."

## 3. CI/CD Pipeline: Infrastructure Destruction (Off-boarding)
**File:** `techflow-azure-devsecops-challenge/.github/workflows/deploy-iac-plan-destroy.yml`

**Prompt:**
> "Create a GitHub Actions workflow named 'Terraform Plan & Destroy' to manage the decommissioning of resources. The workflow should:
> 1. **Trigger Mechanism**: Enable `workflow_dispatch` with a required input named 'confirmation'. The job must only execute if the user explicitly types 'destruir', acting as a manual safety gate.
> 2. **Environment & Security**: Configure the job to run on 'ubuntu-latest' within the 'develop' environment. Use GitHub Secrets to map Azure credentials (SPN) and the Terraform State access key.
> 3. **Terraform Execution**:
>    - Initialize the backend using remote state configuration stored in Azure.
>    - Generate a destruction-specific plan (`terraform plan -destroy`) using the 'develop.tfvars' file.
>    - Display the plan details using `terraform show` for auditing purposes.
>    - Execute the destruction (`terraform apply`) with auto-approval once the manual confirmation is validated.
> Ensure the workflow follows a secure 'least privilege' approach for cloud resource management."

## 4. Application Development: Flask API
**File:** `techflow-azure-devsecops-challenge/app/app.py`

**Prompt:**
> "Develop a simple web API using Python and Flask that fulfills the following technical requirements for a DevSecOps challenge:
> 1. **Endpoint**: Create a single route at '/' that returns a JSON response.
> 2. **Environment Variables**: The application must read an environment variable named 'MY_SECRET'. This variable will be injected at runtime from an Azure Key Vault via Managed Identity.
> 3. **Response Structure**: The JSON response should include the secret value, a welcome message ('Hola Mundo desde TechFlow!'), and a status indicator showing that Managed Identity is active.
> 4. **Containerization Readiness**: Ensure the app is configured to run on host '0.0.0.0' and port 8000, making it compatible with Gunicorn and Azure Container Apps.
> 5. **Security**: Do not hardcode any credentials; rely entirely on system environment variables for sensitive data to ensure security by design."

## 5. Containerization: Dockerfile
**File:** `techflow-azure-devsecops-challenge/app/Dockerfile`

**Prompt:**
> "Create an optimized and secure Dockerfile for a Python Flask application based on the following requirements:
> 1. **Base Image**: Use a lightweight and stable version of Python (e.g., 3.11-slim).
> 2. **Environment Configuration**: Set environment variables to prevent Python from writing .pyc files and to ensure output is unbuffered for better logging.
> 3. **Security (Non-Root User)**: To follow security best practices, create a non-privileged user named 'appuser' and ensure the application runs under this user instead of root.
> 4. **Dependency Management**: Copy the 'requirements.txt' file first and install dependencies using 'pip' with the '--no-cache-dir' flag to reduce image size.
> 5. **Production Ready**: Use Gunicorn as the WSGI HTTP Server, binding it to 0.0.0.0 on port 8000.
> 6. **Performance**: Ensure efficient layer caching by copying the source code only after installing the dependencies."

## 6. Dependency Management: Python Requirements
**File:** `techflow-azure-devsecops-challenge/app/requirements.txt`

**Prompt:**
> "Generate a 'requirements.txt' file for a production-ready Flask application. Include the following specifications:
> 1. **Framework**: Flask version 3.0.3 to ensure compatibility with the latest features and security patches.
> 2. **WSGI Server**: Gunicorn version 22.0.0 to handle HTTP requests in a production environment (Azure Container Apps).
> 3. **Pinning**: Use exact versioning (==) to guarantee environment consistency across local development, CI/CD scanning with Trivy, and cloud deployment."

## 7. Infrastructure: Azure Container Apps Environment
**File:** `techflow-azure-devsecops-challenge/components/compute/container_app_env.tf`

**Prompt:**
> "Write a Terraform resource block to deploy an Azure Container Apps Environment. The configuration must:
> 1. **Naming Convention**: Use a dynamic name following the pattern 'cae-${var.project_name}-${var.environment}' to ensure consistency across different stages.
> 2. **Resource Group & Location**: Reference the resource group name and location from variables provided by the parent module.
> 3. **Modularity**: Ensure this resource is placed within a dedicated 'compute' component to maintain the project's modular structure as required by the technical challenge."

## 8. Infrastructure: Azure Container App Job (Cron Job)
**File:** `techflow-azure-devsecops-challenge/components/compute/cron_job.tf`

**Prompt:**
> "Generate a Terraform resource for an Azure Container App Job to handle scheduled maintenance tasks. The configuration must include:
> 1. **Job Identification**: Name the resource 'cleanup' with a naming convention like 'job-${var.project_name}-cleanup'.
> 2. **Identity & Security**: Use a 'UserAssigned' Managed Identity to ensure the job operates within the secure identity framework established for the project.
> 3. **Schedule**: Configure a `schedule_trigger_config` using a cron expression (e.g., daily at midnight) to demonstrate automation.
> 4. **Container Specification**:
>    - Use a lightweight image like 'alpine:latest'.
>    - The command must execute a shell script that prints 'Job ejecutado con éxito' and then terminates, as specified in the technical challenge requirements.
> 5. **Resource Allocation**: Define minimal CPU (0.25) and memory (0.5Gi) footprints for cost-efficiency."

## 9. Infrastructure: Main Azure Container App (API)
**File:** `techflow-azure-devsecops-challenge/components/compute/main_app.tf`

**Prompt:**
> "Generate a Terraform resource for an Azure Container App that serves as the main API. The configuration must fulfill these DevSecOps requirements:
> 1. **Identity & Authentication**: Implement a 'UserAssigned' Managed Identity. Use this identity for both pulling images from the Azure Container Registry (ACR) and authenticating against Azure Key Vault.
> 2. **Secret Management**: Reference a secret from Key Vault using its Resource ID. Map this secret to a container environment variable named 'MY_SECRET' without hardcoding any values.
> 3. **Init Container**: Include an initialization container named 'init-db-migration' using a lightweight Alpine image. It must execute a command to simulate a migration (e.g., echo a message and sleep for 5 seconds) before the main application starts.
> 4. **Main Container Configuration**:
>    - Name the container 'api-gateway' and use the image from the project's ACR.
>    - Configure resource limits (0.25 CPU, 0.5Gi Memory).
> 5. **Ingress**: Enable external HTTP ingress on port 8000, ensuring 'allow_insecure_connections' is set to false for security.
> 6. **Revision Management**: Set the revision mode to 'Single' and ensure 100% of traffic is routed to the latest revision."

## 10. Infrastructure: Compute Module Variables
**File:** `techflow-azure-devsecops-challenge/components/compute/variables.tf`

**Prompt:**
> "Define the input variables for a Terraform 'compute' module designed to deploy Azure Container Apps. The variables must follow these requirements:
> 1. **Contextual Variables**: Include definitions for 'resource_group_name', 'location', 'project_name', and 'environment' to allow for dynamic resource naming and placement.
> 2. **Security & Identity Integration**: Define 'user_assigned_identity_id' to pass the Managed Identity created in the security module, ensuring the Container App can authenticate securely to Key Vault and ACR.
> 3. **Resource Linking**: Define 'key_vault_secret_id' (specifically requesting the versionless ID for automatic rotation) and 'acr_login_server' to link the compute resources with the existing security and registry components.
> 4. **Documentation**: Provide a clear and concise description for each variable to improve code maintainability and fulfill the 'modular infrastructure' requirement of the DevSecOps challenge."

## 11. Infrastructure: Azure Container Registry (ACR) & RBAC
**File:** `techflow-azure-devsecops-challenge/components/registry/acr.tf`

**Prompt:**
> "Generate a Terraform configuration to deploy an Azure Container Registry (ACR) and its corresponding access controls. The solution must address the following:
> 1. **Registry Setup**: Create an ACR with a dynamic name using project variables and a unique suffix. Use the 'Basic' SKU to optimize costs for this technical evaluation.
> 2. **Security Compliance (Checkov)**: Include specific 'checkov:skip' annotations for policies that cannot be met due to the SKU choice (e.g., SKU-specific features like geo-replication, vulnerability scanning, or retention policies). Provide a clear justification for each skip, such as 'Cost optimization for technical challenge' or 'Simplified networking for evaluation'.
> 3. **Role-Based Access Control (RBAC)**: Implement an 'azurerm_role_assignment' to grant 'AcrPull' permissions to the project's Managed Identity. This ensures the Container App can securely pull images without using admin credentials.
> 4. **Best Practices**: Ensure 'admin_enabled' is set to false to enforce identity-based access over legacy password authentication."

## 12. Infrastructure: Registry Module Outputs
**File:** `techflow-azure-devsecops-challenge/components/registry/outputs.tf`

**Prompt:**
> "Define the Terraform outputs for the 'registry' module. The main objective is to:
> 1. **CI/CD Integration**: Export the 'login_server' attribute of the Azure Container Registry. 
> 2. **Context**: Ensure the output includes a clear description stating that this URL is required for Docker authentication, image tagging, and pushing within the GitHub Actions pipeline.
> 3. **Automation**: Provide this value to the root module so it can be passed to the compute module, fulfilling the requirement for a fully automated and interconnected deployment process."

## 13. Infrastructure: Registry Module Variables
**File:** `techflow-azure-devsecops-challenge/components/registry/variables.tf`

**Prompt:**
> "Define the input variables for a Terraform 'registry' module focused on Azure Container Registry (ACR). The definitions must address the following requirements:
> 1. **Resource Identification**: Include variables for 'resource_group_name', 'location', and 'project_name'.
> 2. **Global Uniqueness**: Define a 'suffix' variable with a default empty value to ensure the ACR name (which must be globally unique in Azure) can be properly randomized.
> 3. **Environment Context**: Include an 'environment' variable to facilitate resource tagging and lifecycle management.
> 4. **Access Control**: Define 'identity_principal_id' to receive the Principal ID from the security module. This is critical for establishing the RBAC assignments (AcrPull) that allow the Container App to pull images securely.
> 5. **Documentation Standards**: Ensure each variable has a clear description to maintain high-quality code standards for the technical evaluation."

## 14. Infrastructure: Security Module (Key Vault & Managed Identity)
**File:** `techflow-azure-devsecops-challenge/components/security/azure_key_vault.tf`

**Prompt:**
> "Develop a Terraform security module to manage secrets and identities in Azure according to DevSecOps principles. The module must include:
> 1. **User Assigned Managed Identity**: Create an identity named 'id-${var.project_name}-${var.environment}' that the application will use to authenticate without credentials.
> 2. **Azure Key Vault**: 
>    - Provision a Key Vault with a globally unique name using a project suffix.
>    - Configure security features such as 'purge_protection_enabled' and a 'soft_delete_retention_days' of 7 days.
>    - **Checkov Compliance**: Add justifications for security policy skips related to public network access and firewall settings, explaining they are for evaluation purposes in a simplified environment.
> 3. **Access Policies**:
>    - Define an admin policy for the current Terraform service principal to manage secrets.
>    - Define a 'Least Privilege' policy for the Managed Identity created in step 1, granting ONLY 'Get' permissions for secrets.
> 4. **Secret Creation**: Provision a secret named 'MY-SECRET' with a sample value. Ensure it includes a 'content_type' and an 'expiration_date' as security best practices for secret lifecycle management."

## 15. Infrastructure: Security Module Outputs
**File:** `techflow-azure-devsecops-challenge/components/security/outputs.tf`

**Prompt:**
> "Define the Terraform outputs for the 'security' module to enable cross-module resource referencing. The outputs must include:
> 1. **Identity Resource ID**: Export the full Resource ID of the User Assigned Managed Identity. Add a description explaining that this is required by the Container App for Azure Key Vault authentication.
> 2. **Versionless Secret ID**: Export the 'versionless_id' of the Key Vault secret. Explicitly mention in the description that using the versionless ID is a best practice to ensure the application always retrieves the latest enabled version of the secret without manual updates.
> 3. **Identity Principal ID**: Export the Principal ID (Object ID) of the Managed Identity. Note that this is strictly required for performing RBAC role assignments (like AcrPull) in other modules.
> 4. **Standards**: Ensure each output has a clear, technical description to maintain the modularity and documentation quality of the TechFlow project."

## 16. Infrastructure: Security Module Variables
**File:** `techflow-azure-devsecops-challenge/components/security/variables.tf`

**Prompt:**
> "Define the input variables for a Terraform 'security' module aimed at provisioning Azure Key Vault and Managed Identities. The requirements include:
> [cite_start]1. **Contextual Scope**: Declare variables for 'resource_group_name' and 'location' to ensure the security stack is deployed in the correct administrative boundary.
> 2. **Global Uniqueness**: Include a 'suffix' variable with a default empty string. [cite_start]This is essential to generate a globally unique name for the Key Vault, as mandated by Azure platform constraints[cite: 11].
> [cite_start]3. **Naming Strategy**: Define 'project_name' and 'environment' variables to allow the module to programmatically derive unique names for the Managed Identity and Key Vault, ensuring alignment with the project's naming convention[cite: 13, 22].
> [cite_start]4. **Standardization**: Provide technical descriptions for each variable to facilitate maintainability and clear documentation for the DevSecOps challenge[cite: 22, 47]."

## 17. Configuration: Environment Variables (develop.tfvars)
**File:** `techflow-azure-devsecops-challenge/develop.tfvars`

**Prompt:**
> "Create a Terraform variable definitions file (tfvars) specifically for the 'develop' environment of the TechFlow project. The file must:
> 1. **Core Identification**: Set the 'project_name' to 'techflow' and the 'environment' to 'develop'.
> 2. **Regional Placement**: Define the Azure region as 'eastus' for all resource provisioning.
> 3. **Uniqueness & Organization**: 
>    - Provide a unique alphanumeric 'suffix' (e.g., '29413') to prevent naming collisions for global resources like Key Vault and ACR.
>    - Specify the 'resource_group_name' as 'rg-techflow-develop' to align with the automated deployment pipelines.
> 4. **Project Alignment**: Ensure these values match the requirements for a serverless, container-based architecture as specified in the DevSecOps challenge documentation."

## 18. Infrastructure Orchestration: Main Entry Point
**File:** `techflow-azure-devsecops-challenge/main.tf`

**Prompt:**
> "Create a Terraform root configuration file (`main.tf`) to orchestrate the deployment of the TechFlow infrastructure. The configuration must:
> 1. **Resource Group**: Provision a central Azure Resource Group using the project name and environment variables for naming.
> 2. **Modular Architecture**: Integrate three local modules:
>    - **Security**: Deploy this first to provide the Managed Identity and Key Vault secrets.
>    - **Registry**: Deploy the Azure Container Registry, passing the Principal ID from the security module to configure RBAC.
>    - **Compute**: Deploy the Container Apps and Jobs, consuming the Identity ID, Secret ID, and ACR Login Server from the previous modules.
> 3. **Dependency Injection**: Ensure a clear flow of data between modules to maintain a 'secure by design' architecture where the compute layer depends on the security layer for identity-based access.
> 4. **Automation**: Standardize the location and naming across all modules to ensure a consistent and automated deployment via CI/CD."

## 19. Infrastructure: Providers & Backend Configuration
**File:** `techflow-azure-devsecops-challenge/providers.tf`

**Prompt:**
> "Configure the Terraform settings and providers for a secure Azure deployment. The configuration must include:
> 1. **Version Constraints**: Require Terraform version 1.10.0 or higher and pin the 'azurerm' provider to version ~> 4.0 and 'azuread' to ~> 3.0 to ensure stability and access to the latest Azure features.
> 2. **Remote Backend**: Define an empty 'azurerm' backend block to allow the CI/CD pipeline to inject the remote state configuration (Storage Account, Container, and Key) dynamically during initialization.
> 3. **Provider Customization (AzureRM)**:
>    - Configure 'key_vault' features to allow 'purge_soft_delete_on_destroy' and 'recover_soft_deleted_key_vaults', facilitating easier cleanup during the technical test.
>    - Set 'resource_group' features to allow deletion even if it contains resources to streamline the infrastructure destruction process.
> 4. **Azure AD Integration**: Initialize the 'azuread' provider to manage identities and service principal configurations required for the DevSecOps workflow."

## 20. Infrastructure: Root Module Variables
**File:** `techflow-azure-devsecops-challenge/variables.tf`

**Prompt:**
> "Define the global input variables for the Terraform root module of the TechFlow project. The configuration must:
> 1. **Core Parameters**: Declare variables for 'resource_group_name', 'location', and 'project_name' to serve as the foundation for resource naming and regional placement.
> 2. **Environment & Traceability**: Include an 'environment' variable with a default empty value to allow for environment-specific configurations (e.g., develop, prod) and resource tagging.
> 3. **Conflict Resolution**: Define a 'suffix' variable to handle global naming constraints in Azure for shared services like Storage, ACR, and Key Vault.
> 4. **Standardization**: Provide detailed technical descriptions for each variable. This ensures that any engineer or automated system (like GitHub Actions) can clearly understand the purpose and requirements of each input, fulfilling the DevSecOps documentation standards."