# Project Journal

Building this serverless Azure portfolio was a fun learning experience. Moving from clicking around the Azure Portal to set it up manually to fully automating the infrastructure.

Below are the most significant hurdles I faced, how I troubleshot them, and what I learned in the process.

## 1. The Reason for the Project
**The Problem:** 
I am currently studying for the AZ-104 exam, but I wanted to also have a project the proves my skills along with my knowledge

**The Solution:**
I searched for projects and cam upon the [Cloud Resume Challenge](https://cloudresumechallenge.dev/). Hosting my portfolio on Azure and automating it's deployment was a great opportunity to update my old Portfolio website and showcase my skills.

## 2. Skipping HTML Resume 
**The Problem:** 
The first few steps of the challenge were to recreate my resume in HTML and CSS. I assumed this is to showcase my ability to code in HTML and CSS.

**The Solution:**
Thankfully I have already created a portfolio website previously with multiple HTML pages, CSS, and Javascript so I skipped those steps knowing my full website, versus just a HTML resume, would showcase my frontend coding skills more. And keeping my resume in PDF form allows recruits to more easily download it.

## 3. Transferring my website from Github to Azure
**The Problem:** 
I was already hosting my website via Github Pages

**The Solution:**
I learned how to manually created a Azure Static Website and link the code to a Github repository. This automatically created a Github Action that forwarded my code when pushed.

## 4. Outdated Portfolio
**The Problem:** 
My website had outdated information and needed a new proffesional look.

**The Solution:**
I completely rewrote the HTML and CSS creating a CRT monitor style look for links with a minimalistic colour pallette for a sleeker look then my old website. I have archived my old website code [Here](https://github.com/BrendenScott/Portfolio-Old-Website-Code)

## 5. Total Visitor Counter
**The Problem:** 
I created a total visitor counter with python that linked to the Cosmos Database with a connection string. But it would update everytime the page was refreshed. I wanted to keep it more accurate but did not want to store information like IP addresses

**The Solution:**
I added a function to the JavaScript file that uses the browser's temporary memory to remember if it has already fetched the visitor count for the current session. When the page is refreshed, it just displays that saved number instead of calling the API again to update the database. Closing and re opening the browser adds to the count but it is at least more accurate then adding it per page refresh.