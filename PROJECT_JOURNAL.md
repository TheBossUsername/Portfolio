# Project Journal

Building this serverless Azure portfolio was a fun learning experience. Moving from clicking around the Azure Portal to fully automating the infrastructure required a shift in how I approached problem-solving.

Below are the most significant hurdles I faced, how I troubleshot them, and what I learned in the process.

## 1. The Reason for the Project
**The Problem:** 
I am currently studying for the AZ-104 exam, but I wanted a project that proves my skills alongside my theoretical knowledge.

**The Solution:**
I searched for projects and came across the [Cloud Resume Challenge](https://cloudresumechallenge.dev/). Hosting my portfolio on Azure and automating its deployment was a great opportunity to update my old portfolio website and showcase my technical skills.

## 2. Skipping the HTML Resume 
**The Problem:** 
The first few steps of the challenge were to recreate my resume in HTML and CSS. I assumed this was to showcase my ability to code in HTML and CSS.

**The Solution:**
Thankfully, I had already created a portfolio website with multiple HTML pages, CSS, and JavaScript. I skipped those steps knowing my full website—versus just an HTML resume—would showcase my frontend coding skills more effectively. Additionally, keeping my resume in PDF form allows recruiters to download it more easily.

## 3. Transferring My Website from GitHub to Azure
**The Problem:** 
I was already hosting my website via GitHub Pages.

**The Solution:**
I learned how to manually create an Azure Static Web App and link the code to a GitHub repository. This automatically created a GitHub Actions workflow that forwarded my code whenever I pushed an update.

## 4. Outdated Portfolio
**The Problem:** 
My website had outdated information and needed a new, professional look.

**The Solution:**
I completely rewrote the HTML and CSS, creating a CRT monitor-style look for links with a minimalist color palette. This provided a sleeker look than my old website. I have archived my old website code [Here](https://github.com/BrendenScott/Portfolio-Old-Website-Code).

## 5. Total Visitor Counter
**The Problem:** 
I created a total visitor counter using Python that linked to the Cosmos DB via a connection string. However, it would update every time the page was refreshed. I wanted to keep it accurate but did not want to store sensitive information like IP addresses.

**The Solution:**
I added a function to the JavaScript file that uses the browser's temporary memory to remember if it has already fetched the visitor count for the current session. When the page is refreshed, it just displays that saved number instead of calling the API again to update the database. Closing and reopening the browser adds to the count, which is at least more accurate than adding to it per page refresh.

## 6. Infrastructure as Code
**The Problem:** 
The website was complete, but it was built out manually through the Azure Portal. For the challenge and my own learning, I needed to build everything I could through Infrastructure as Code (IaC).

**The Solution:**
The challenge recommends using ARM Templates, but I already have a pretty good understanding of them. I wanted to learn a cloud-agnostic tool, so I chose Terraform.

## 7. The Chicken and Egg Problem: Bootstrapping Terraform
**The Problem:** 
I wanted to completely build everything in Azure using Terraform, but before I could, I needed an Azure Service Principal for GitHub to run the code through, along with a place on Azure to securely store the `terraform.tfstate` file. 

**The Solution:**
I learned about "bootstrapping" infrastructure. I wrote a PowerShell script (`bootstrap.ps1`) to use the Azure CLI to provision the initial Resource Group and Storage Container before Terraform ever runs.

## 8. Moving from Client Secrets to Passwordless Deployments (OIDC)
**The Problem:**
Initially, I authenticated GitHub Actions to Azure using the traditional OAuth 2.0 Client Credentials flow. This required generating a **Client Secret** tied to an Azure Service Principal (Enterprise Application) and hardcoding that secret directly into GitHub Secrets. Although acceptable, I learned there is a risk: if my GitHub was compromised, attackers could steal the static secret. Even after securing GitHub, I would have to remember to manually rotate the secret in Azure.

**The Solution:**
I completely refactored the authentication to use **OpenID Connect (OIDC) Federation**. By creating a federated identity credential, I established a direct trust relationship between my specific GitHub repository branch and the Azure Service Principal. This improves security by removing **Client Secrets** entirely and instead relying on temporary access via GitHub. Now, I don't have to worry about rotating secrets and can focus strictly on securing my GitHub credentials.

## 9. Azure Static Website Deployment Token
**The Problem:**
My infrastructure pipeline (Terraform) built the Azure Static Web App perfectly, but in order to push code to the website, I needed the Azure Static Website Deployment Token. I needed to securely store it in GitHub Secrets. Normally, code cannot upload secrets, but to reduce manual steps and human error, I wanted to automate storing this token.

**The Solution:**
Thankfully, GitHub offers Personal Access Tokens (PATs), which I created for the repository, allowing the workflow to create secrets. I updated my Terraform configuration to extract this deployment token upon creation and securely push it directly into my GitHub repository secrets using the GitHub CLI.

## 🚀 Key Takeaways

* **Infrastructure as Code is powerful.** I originally set resources to be created in a region where APIs were not allowed. After I changed the location variable, it was amazing to see Terraform automatically delete the previously made resources and dynamically recreate them in the new location.
* **Cloud Coding Security.** I was not aware of GitHub Secrets before this project, nor did I know there were ways to securely store sensitive variables on a public repository.
* **CI/CD.** I learned how to use GitHub Actions as a robust way to set up a CI/CD pipeline.
* **Infrastructure Cloneability:** I learned how to make my infrastructure portable. By parameterizing my Terraform code and providing a `terraform.tfvars` file, I made the repository easily cloneable for other engineers. This approach allows others to spin up their own version of the project without me leaking any sensitive configuration names or secrets.
* **Extremely Low Cost:** By creating this project using serverless resources, like the Azure Functions Consumption Plan and Cosmos DB serverless capacity mode, I am able to keep my monthly hosting costs near zero.

## 🔮 What I'd Do Differently Next Time
* Skip manually setting up resources in the Azure Portal and use Terraform from the very beginning.
* Set up my custom domain through Azure next time to skip manually having to update a third-party website's DNS records.