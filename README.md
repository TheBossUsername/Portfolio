# Portfolio Via Azure

A fully automated, serverless personal portfolio website hosted on Microsoft Azure. Fully automated via GitHub Actions and Terraform and features an API-driven visitor counter.

This project is built using the principles of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/).

## 📖 The Journey & Lessons Learned

Building this project involved navigating several challenges. You can read my full write-up on the troubleshooting process and what I learned here: [PROJECT_JOURNAL.md](PROJECT_JOURNAL.md)

## 🏗️ Architecture Overview

- **Frontend:** HTML/CSS/JS hosted on an **Azure Static Web App (SWA)**.
- **Backend/API:** A Serverless **Python Azure Function** (v2 programming model) that interacts with the database.
- **Database:** **Azure Cosmos DB** (Serverless SQL API) to store and retrieve the visitor count.
- **Infrastructure as Code (IaC):** **Terraform** provisions all Azure resources.
- **CI/CD:** **GitHub Actions** handles infrastructure deployment and frontend/API code releases.
- **Security:** OpenID Connect (OIDC) is used to establish a passwordless, federated trust between GitHub Actions and Azure.

## 📂 Repository Structure

```text
.
├── .github/workflows/
│   ├── deploy-backend.yml    # Terraform CI/CD pipeline (Infra)
│   └── deploy-frontend.yml   # Azure Static Web Apps CI/CD pipeline (Frontend & API)
├── api/
│   ├── function_app.py       # Python Azure Function (Visitor Counter)
│   └── ...                   # requirements.txt, host.json, etc.
├── frontend/                 # Static website assets (HTML, CSS, JS)
└── infra/
    ├── bootstrap.ps1         # PowerShell script to configure OIDC, Service Principals & TF State
    ├── database.tf           # Cosmos DB Terraform definitions
    ├── frontend.tf           # Azure Static Web App Terraform definitions
    ├── main.tf               # Core Terraform configuration & Providers
    ├── outputs.tf            # Terraform output variables
    ├── terraform.tfvars      # Environment variables (Project prefix, custom domain, etc.)
    └── variables.tf          # Terraform variable definitions
```

## 🛠️ Prerequisites

To deploy this project from scratch, ensure you have the following installed locally:
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (`az`)
* [GitHub CLI](https://cli.github.com/) (`gh`)
* [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
* An active Azure Subscription
* A GitHub repository containing this code

## 🚀 Setup & Deployment Guide

### 1. Update Configurations
Before deploying, update the configuration files to match your environment:
1. Open `infra/terraform.tfvars` and update the `project_prefix`, `location`, and custom domain settings.
2. **Important:** Change the setting `enable_custom_domain = true` to false `enable_custom_domain = false`. Even if you have a custom domain you would like to use, still change it to false for the initial setup. The reason for this is you will need to manually add a CNAME DNS record on your domain registrar’s website pointing to the Azure Static Website's address which is not created until the first deployment.
3. If you would like to change the location, make sure it is one of these listed `centralus, westus2, eastus2, westeurope, eastasia` since this website utilizes serverless backend APIs (Azure Functions)

### 2. Configure GitHub Authentication (GH_PAT)
The infrastructure pipeline automatically saves the Azure Static Web Apps deployment token to your GitHub secrets; this is needed for the frontend deployment action to prove it has authorization to modify the Static Web App resource:
1. Login to [Github](https://github.com/).
2. Click your profile in the top right
3. Scroll down and click **Developer Settings** on the left
4. Click the **Personal access token** then **Fine-grained tokens**.
5. Click **Generate new token**.
6. Name it how you would like, I named mine **Portfolio SWA Token Sync**
7. Set expiration date based on how often you would like to rotate the secret for security, I set mine to 90.
8. Choose **Only select repositories**, and choose the repository you cloned this code to
9. Click **Add permissions** and search for **Secrets**, select that and click out of the pop up box.
10. In the permissions you should now see Secrets, change the **Access:** from **Read-Only** to **Read and write**, then click generate
11. Copy the value
12. Go to your repository settings then **Secrets and variables** then **Actions**.
13. Create a new repository secret named `GH_PAT` and paste your token.

### 3. Bootstrap the Environment
The `bootstrap.ps1` script sets up the Terraform remote state backend, provisions an Azure Service Principal, configures OIDC federation, and injects the necessary secrets directly into your GitHub repository.

1. Open a PowerShell terminal and log in to your accounts:
   ```powershell
   az login
   gh auth login
   ```
*Make sure you choose the azure subscription you want this built out in*

2. Navigate to the infrastructure folder and run the script:
   ```powershell
   cd infra
   .\bootstrap.ps1
   ```
*If successful, the script will output that it has successfully injected `ARM_CLIENT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`, and `TF_STORAGE_ACCOUNT` into your GitHub secrets.*

### 4. Trigger the Pipelines
Once bootstrapped, your GitHub Actions pipelines are ready to take over.

1. Navigate to the **Actions** tab in your GitHub repository.
2. Run the **Deploy Backend** workflow. This will use Terraform to create your Resource Group, Cosmos DB, and Static Web App.

**Note:** *If you would like to set up a custom domain, Terraform with output the Azure Static Website's address for you to copy in the Action logs*

3. Once the backend workflow completes successfully, run the **Deploy Frontend & API** workflow. This will bundle your HTML/JS site and Python function, deploying them to the Azure Static Web App.

### 5. Custom Domain Setup (Optional)
If you want to use a custom domain:
1. In the **Deploy Backend** Action terraform output the default URL in the logs, find and copy that URL

**Note:** Alternatively you can go to your newly created Azure Static Web App in the Azure Portal and copy the default URL there.

2. Go to your DNS provider and create a `CNAME` record, with the host as "@" and the value as the SWA URL.
3. Update `infra/terraform.tfvars` to set `enable_custom_domain = true` and enter the address of your domain into the variable **custom_domain_name**.
4. Push the change to trigger the **Deploy Backend** workflow, which will finalize the custom domain binding via Terraform.

### 6. Automaticaly Trigger Github Actions on Push (Optional)
1. Open `.github/workflows/deploy-backend.yml` and `.github/workflows/deploy-frontend.yml`. Update the `if: github.repository == 'BrendenScott/Portfolio'` line to match your own GitHub username and repository name.

## 💻 Local Development

To run the Azure Function locally:
1. Install [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local).
2. Retrieve your Cosmos DB connection string from the Azure Portal.
3. Add the connection string to a `local.settings.json` file in the `api/` directory:
   ```json
   {
     "IsEncrypted": false,
     "Values": {
       "AzureWebJobsStorage": "UseDevelopmentStorage=true",
       "FUNCTIONS_WORKER_RUNTIME": "python",
       "CosmosDbConnectionString": "YOUR_CONNECTION_STRING_HERE"
     }
   }
   ```
4. Start the function:
   ```bash
   cd api
   func start
   ```

