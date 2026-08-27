$ErrorActionPreference = "Stop"

Write-Host "`n>>> [1/6] Reading Configuration from terraform.tfvars..." -ForegroundColor Cyan

$tfvarsPath = ".\terraform.tfvars"
if (-not (Test-Path $tfvarsPath)) {
    Write-Host "[ERROR] terraform.tfvars not found! Please ensure you are in the 'infra' folder and the file exists." -ForegroundColor Red
    exit 1
}

# Extract variables using Regular Expressions
$Prefix = (Select-String -Path $tfvarsPath -Pattern 'project_prefix\s*=\s*"([^"]+)"').Matches.Groups[1].Value
$Env    = (Select-String -Path $tfvarsPath -Pattern 'environment\s*=\s*"([^"]+)"').Matches.Groups[1].Value
$Loc    = (Select-String -Path $tfvarsPath -Pattern 'location\s*=\s*"([^"]+)"').Matches.Groups[1].Value

if (-not $Prefix -or -not $Env -or -not $Loc) {
    Write-Host "[ERROR] Could not read project_prefix, environment, or location from terraform.tfvars." -ForegroundColor Red
    exit 1
}

# Construct the globally unique names
$RESOURCE_GROUP_NAME = "rg-$Prefix-$Env-state"
$CONTAINER_NAME = "tfstate"
$RANDOM_ID = Get-Random -Minimum 1000 -Maximum 9999
$STORAGE_ACCOUNT_NAME = "tf$Prefix$Env$RANDOM_ID".ToLower().Replace("-","")

Write-Host "`n>>> [2/6] Running Dependency Checks..." -ForegroundColor Cyan

# Verify Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Azure CLI ('az') is not installed or not in your PATH." -ForegroundColor Red
    Write-Host "Please install it using Windows Package Manager:" -ForegroundColor Yellow
    Write-Host "  winget install -e --id Microsoft.AzureCLI`n" -ForegroundColor White
    exit 1
}

# Verify GitHub CLI is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] GitHub CLI ('gh') is not installed or not in your PATH." -ForegroundColor Red
    Write-Host "Please install it using Windows Package Manager:" -ForegroundColor Yellow
    Write-Host "  winget install --id GitHub.cli`n" -ForegroundColor White
    exit 1
}

Write-Host "All CLI dependencies detected." -ForegroundColor Green

Write-Host "`n>>> [3/6] Checking Azure Authentication..." -ForegroundColor Cyan
try {
    $null = az account show 2>$null
    Write-Host "Active Azure session found." -ForegroundColor Green
} catch {
    Write-Host "No active Azure session detected. Launching 'az login'..." -ForegroundColor Yellow
    az login | Out-Null
}

Write-Host "`n>>> [4/6] Checking GitHub Authentication..." -ForegroundColor Cyan
$ghStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "No active GitHub CLI session detected. Launching 'gh auth login'..." -ForegroundColor Yellow
    gh auth login
} else {
    Write-Host "Active GitHub CLI session found." -ForegroundColor Green
}

Write-Host "`n>>> [5/6] Provisioning Terraform Remote State Storage..." -ForegroundColor Cyan
az group create --name $RESOURCE_GROUP_NAME --location $Loc --output none
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob --output none
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --output none

Write-Host "`n>>> [6/6] Configuring Identity & GitHub OIDC Federation..." -ForegroundColor Cyan
$SUBSCRIPTION_ID = az account show --query id -o tsv
$TENANT_ID = az account show --query tenantId -o tsv

# Automatically fetch owner and repository details including immutable IDs via GitHub API
Write-Host "Fetching repository metadata and immutable IDs from GitHub..." -ForegroundColor Gray
$repoJson = gh api repos/:owner/:repo
$repoObj = $repoJson | ConvertFrom-Json

$ownerLogin = $repoObj.owner.login
$ownerId    = $repoObj.owner.id
$repoName   = $repoObj.name
$repoId     = $repoObj.id

if (-not $ownerLogin -or -not $ownerId -or -not $repoName -or -not $repoId) {
    Write-Host "[ERROR] Could not determine GitHub repository metadata via 'gh api'. Please ensure you are in a cloned git repo linked to GitHub." -ForegroundColor Red
    exit 1
}

$APP_NAME = "sp-github-terraform-$RANDOM_ID"
Write-Host "Creating Microsoft Entra ID Application ($APP_NAME)..." -ForegroundColor Gray
$APP_ID = az ad app create --display-name $APP_NAME --query appId -o tsv

Start-Sleep -Seconds 3

Write-Host "Creating Service Principal..." -ForegroundColor Gray
$SP_OBJECT_ID = az ad sp create --id $APP_ID --query id -o tsv

Write-Host "Assigning 'Contributor' role at subscription scope..." -ForegroundColor Gray
az role assignment create --role "Contributor" --scope "/subscriptions/$SUBSCRIPTION_ID" --assignee-object-id $SP_OBJECT_ID --assignee-principal-type "ServicePrincipal" --output none

Write-Host "Establishing OpenID Connect (OIDC) Federated Trust with GitHub..." -ForegroundColor Gray
$CRED_NAME = "github-action-federation-$RANDOM_ID"

# Build payload hashtable with the immutable OIDC subject format including both IDs
$CredPayload = @{
    name         = $CRED_NAME
    issuer       = "https://token.actions.githubusercontent.com"
    subject      = "repo:${ownerLogin}@${ownerId}/${repoName}@${repoId}:ref:refs/heads/main"
    description  = "OIDC Federation for GitHub Actions main branch"
    audiences    = @("api://AzureADTokenExchange")
}
$ParametersJson = $CredPayload | ConvertTo-Json -Depth 3
$TempJsonPath = [System.IO.Path]::GetTempFileName()
$ParametersJson | Out-File -FilePath $TempJsonPath -Encoding utf8

try {
    az ad app federated-credential create --id $APP_ID --parameters "@$TempJsonPath" --output none
} finally {
    Remove-Item $TempJsonPath -ErrorAction SilentlyContinue
}

# Push identifier configuration straight to GitHub
$APP_ID | gh secret set ARM_CLIENT_ID
$SUBSCRIPTION_ID | gh secret set ARM_SUBSCRIPTION_ID
$TENANT_ID | gh secret set ARM_TENANT_ID
$STORAGE_ACCOUNT_NAME | gh secret set TF_STORAGE_ACCOUNT

Write-Host "Secrets injected to GitHub : ARM_CLIENT_ID, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, TF_STORAGE_ACCOUNT" -ForegroundColor Gray