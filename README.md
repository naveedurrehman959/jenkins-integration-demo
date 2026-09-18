# Lab 4: Git Integration with Jenkins

![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins&logoColor=white)
![Git](https://img.shields.io/badge/Git-Version%20Control-F05032?logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?logo=github&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-Runtime-339933?logo=node.js&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Environment-FCC624?logo=linux&logoColor=black)

## 📌 Overview

This lab demonstrates how to integrate **GitHub with Jenkins** to build a basic Continuous Integration (CI) workflow.

The project uses a simple Node.js HTTP application stored in GitHub. Jenkins checks out the source code, installs dependencies, runs tests, starts the application for verification, and records build information.

The lab also covers automated build triggering through **SCM polling**, feature-branch builds, build parameters, monitoring, troubleshooting, and an end-to-end integration test.

> **Lab source:** Al Nafi International College — *Lab 4: Using Git Integration with Jenkins*.

---

## 🎯 Objectives

By completing this lab, you learn how to:

- Install and configure Jenkins on Linux
- Install and configure Git
- Create and manage a GitHub repository
- Connect Jenkins to a Git repository
- Configure Jenkins Source Code Management (SCM)
- Create a Jenkins Freestyle project
- Configure Node.js in Jenkins
- Automate dependency installation and testing
- Trigger builds when Git changes are detected
- Configure GitHub webhook concepts
- Use Jenkins SCM polling
- Build different Git branches
- Use Jenkins build parameters
- Monitor Jenkins and troubleshoot common issues
- Perform an end-to-end Git → Jenkins integration test

---

## 🏗️ Architecture

```text
Developer
    │
    │ git push
    ▼
┌───────────────┐
│    GitHub     │
│ Repository    │
└───────┬───────┘
        │
        │ SCM Polling / Webhook
        ▼
┌─────────────────────┐
│       Jenkins       │
│                     │
│  Git Checkout       │
│       ↓             │
│  npm install        │
│       ↓             │
│  npm test           │
│       ↓             │
│  Start Application  │
│       ↓             │
│  curl Verification  │
└─────────┬───────────┘
          │
          ▼
   Build Result / Logs
```

GitHub webhooks can deliver repository events to an external server as they happen, while SCM polling periodically checks the repository for changes. Jenkins supports both approaches. 

---

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Linux | Lab environment |
| Jenkins | CI automation server |
| Git | Version control |
| GitHub | Remote source-code repository |
| Node.js | Application runtime |
| npm | Dependency and script execution |
| Bash | Build and troubleshooting scripts |
| curl | Application endpoint testing |

---

# 🚀 Lab Implementation

## 1. Environment Setup

Update the Linux machine and install Java and required utilities.

```bash
sudo apt update
sudo apt install -y openjdk-11-jdk curl wget gnupg2 software-properties-common
```

Verify Java:

```bash
java -version
```

---

## 2. Jenkins Installation

Add the Jenkins repository:

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
```

Install Jenkins:

```bash
sudo apt update
sudo apt install -y jenkins
```

Start and enable Jenkins:

```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins
```

Get the initial administrator password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Then open:

```text
http://localhost:8080
```

Complete the initial Jenkins setup and install the suggested plugins.

---

## 3. Install and Configure Git

```bash
sudo apt install -y git
```

Verify:

```bash
git --version
```

Configure Git:

```bash
git config --global user.name "Jenkins User"
git config --global user.email "jenkins@localhost"
```

---

# 📦 GitHub Repository

Create a GitHub repository named:

```text
jenkins-integration-demo
```

The lab uses a Node.js HTTP application with a simple test script.

Clone the repository:

```bash
cd ~

git clone https://github.com/YOUR_USERNAME/jenkins-integration-demo.git

cd jenkins-integration-demo
```

---

## 🟢 Node.js Application

Create `app.js`:

```javascript
const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World from Jenkins Integration Demo!\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
```

---

## 📄 package.json

The project uses npm scripts for application startup and testing:

```json
{
  "name": "jenkins-integration-demo",
  "version": "1.0.0",
  "description": "Demo project for Jenkins integration",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"Running tests...\" && echo \"All tests passed!\""
  },
  "author": "Jenkins User",
  "license": "MIT"
}
```

---

## 🧪 Test Script

Create:

```text
test/app.test.js
```

The test demonstrates a basic automated test execution flow and returns a successful exit code when the checks complete.

---

## 📤 Push Code to GitHub

```bash
git add .

git commit -m "Initial commit: Add Node.js application with tests"

git push origin main
```

---

# 🔧 Jenkins Configuration

## Required Plugins

The lab configures Jenkins with:

- Git plugin
- GitHub plugin
- GitHub Integration Plugin
- NodeJS plugin

Jenkins' Git plugin provides Git checkout functionality for Pipeline jobs, including branch and credentials configuration. 

---

## Node.js Configuration

Navigate to:

```text
Manage Jenkins
→ Global Tool Configuration
→ NodeJS
```

Add a Node.js installation and make it available to the Jenkins job.

---

# 🏗️ Create Jenkins Job

Create a new:

```text
Freestyle project
```

Suggested name:

```text
jenkins-git-integration-demo
```

### Source Code Management

Select:

```text
Git
```

Repository:

```text
https://github.com/YOUR_USERNAME/jenkins-integration-demo.git
```

Branch:

```text
*/main
```

For a public repository, credentials are not required for the basic lab setup.

---

# ⚙️ Build Configuration

Configure the Node.js environment and add an **Execute shell** build step.

Example build flow:

```bash
#!/bin/bash

echo "Starting build process..."
echo "Current directory: $(pwd)"

echo "Files in directory:"
ls -la

echo "Installing dependencies..."
npm install

echo "Running tests..."
npm test

echo "Starting application..."
timeout 10s npm start &

APP_PID=$!

echo "Waiting for application..."
sleep 3

echo "Testing application endpoint..."
curl -f http://127.0.0.1:3000 || echo "Application test failed"

echo "Stopping application..."
kill $APP_PID 2>/dev/null || true

echo "Build completed successfully!"
```

---

# ▶️ Manual Build Test

From the Jenkins job:

```text
Build Now
→ Build Number
→ Console Output
```

Verify that:

- Git checkout succeeds
- Dependencies are installed
- Tests pass
- Node.js application starts
- `curl` receives a response
- Jenkins marks the build successful

---

# 🔄 Automated Build Trigger

The lab demonstrates two concepts:

### GitHub Webhook

A webhook can notify Jenkins immediately after a repository event such as a push. GitHub documents webhooks as a mechanism for delivering event notifications to external servers. 

Typical Jenkins webhook endpoint:

```text
http://YOUR_JENKINS_IP:8080/github-webhook/
```

### SCM Polling

For environments where GitHub cannot directly reach the Jenkins server, the lab uses SCM polling.

Configure:

```text
Build Triggers
→ Poll SCM
```

Schedule:

```text
H/2 * * * *
```

This checks for changes approximately every two minutes.

Jenkins documents `pollSCM` as a trigger for polling source-control changes. 

---

# 🧪 Test Automated Trigger

Make a change:

```bash
cd ~/jenkins-integration-demo

cat >> app.js << 'EOF'

// Added feature: current timestamp
console.log('Application started at:', new Date().toISOString());
EOF
```

Commit and push:

```bash
git add app.js

git commit -m "Add timestamp logging feature"

git push origin main
```

Jenkins should detect the change through SCM polling and start a new build.

---

# 🌿 Feature Branch Testing

Configure Jenkins to allow multiple branches:

```text
Branches to build:
*/*
```

Create a feature branch:

```bash
git checkout -b feature/enhanced-logging
```

Add the enhanced logging implementation, then:

```bash
git add .

git commit -m "Add enhanced logging functionality"

git push origin feature/enhanced-logging
```

Jenkins can then be configured to build the appropriate branch.

> For production-grade branch automation, Jenkins also supports Multibranch Pipeline projects and Pipeline as Code using a `Jenkinsfile`. 

---

# 🎛️ Build Parameters

Enable:

```text
This project is parameterized
```

Add:

```text
Name: GIT_BRANCH_NAME
Default Value: main
Description: Git branch to build
```

The branch configuration can then reference:

```text
*/${GIT_BRANCH_NAME}
```

This allows the same Jenkins job to select different branches at build time.

---

# 📊 Build Report

The lab creates a build report containing information such as:

```text
Job Name
Build Number
Build Status
Git Branch
Git Commit
Build Timestamp
```

This helps demonstrate how Jenkins environment variables can be used during a build.

---

# 🔍 Monitoring

A monitoring script is created to inspect:

- Jenkins service status
- Jenkins activity
- Git repository status
- Recent Git commits

Example:

```bash
~/monitor-builds.sh
```

---

# 🛠️ Troubleshooting

## Jenkins Service Not Running

Check:

```bash
sudo systemctl status jenkins
```

Restart:

```bash
sudo systemctl restart jenkins
```

Check logs:

```bash
sudo journalctl -u jenkins -f
```

---

## Git Access Problem

Test repository access:

```bash
git clone https://github.com/YOUR_USERNAME/jenkins-integration-demo.git test-clone
```

Test using the Jenkins user:

```bash
sudo -u jenkins git clone https://github.com/YOUR_USERNAME/jenkins-integration-demo.git
```

For private repositories, configure Jenkins credentials rather than embedding credentials in repository URLs. Jenkins' Git documentation recommends using `credentialsId` for secured repositories. 

---

## Build Failure

Check:

```bash
git --version
java -version
```

Validate shell syntax:

```bash
bash -n your-build-script.sh
```

Check Jenkins workspace permissions:

```bash
sudo chown -R jenkins:jenkins /var/lib/jenkins/workspace/
```

---

## Polling Not Working

Check:

1. SCM polling is enabled.
2. The repository URL is correct.
3. The branch specification is correct.
4. Jenkins can access GitHub.
5. The Jenkins system clock is correct.
6. A new commit actually exists on the configured branch.

---

# 🔁 End-to-End Workflow

The completed workflow is:

```text
1. Developer writes code
        ↓
2. Code committed with Git
        ↓
3. git push
        ↓
4. GitHub repository updated
        ↓
5. Jenkins detects SCM change
        ↓
6. Jenkins checks out source code
        ↓
7. npm install
        ↓
8. npm test
        ↓
9. Application starts
        ↓
10. curl endpoint verification
        ↓
11. Build report generated
        ↓
12. Jenkins records build result
```

---

# 📁 Example Project Structure

```text
jenkins-integration-demo/
├── app.js
├── package.json
├── package-lock.json
├── test/
│   └── app.test.js
├── integration-test.js
└── README.md
```

---

# ✅ Lab Outcomes

After completing the lab, you should have practical experience with:

- Jenkins installation and administration
- Git and GitHub integration
- Jenkins SCM configuration
- Freestyle job creation
- Node.js build automation
- Automated testing
- SCM polling
- GitHub webhook concepts
- Feature branch builds
- Parameterized builds
- Jenkins monitoring
- Build troubleshooting
- End-to-end CI workflow

---

# 🚀 Next Steps

This lab provides a foundation for more advanced DevOps automation.

Recommended next steps:

1. Convert the Freestyle job into a **Jenkins Pipeline**.
2. Store the pipeline in a `Jenkinsfile`.
3. Use a **Multibranch Pipeline** for branch automation.
4. Add Docker image building.
5. Add Docker Hub or GitHub Container Registry.
6. Add security scanning.
7. Add automated deployment.
8. Add Kubernetes deployment.
9. Add notifications.
10. Build a complete CI/CD pipeline.

Jenkins officially supports Pipeline as Code, where the pipeline definition is stored and versioned in source control as a `Jenkinsfile`. 

---

## 📚 References

- [Jenkins Git Plugin Documentation](https://www.jenkins.io/doc/pipeline/steps/git/)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/pipeline/getting-started-pipelines/)
- [Jenkins Pipeline as Code](https://www.jenkins.io/doc/book/pipeline/pipeline-as-code/)
- [Jenkins GitHub Plugin](https://plugins.jenkins.io/github/)
- [GitHub Webhooks Documentation](https://docs.github.com/en/webhooks/about-webhooks)

---

## 👨‍💻 Lab Summary

**Lab:** Git Integration with Jenkins  
**Application:** Node.js HTTP server  
**Repository:** `jenkins-integration-demo`  
**CI Tool:** Jenkins  
**SCM:** Git + GitHub  
**Build Tool:** npm  
**Automation:** SCM polling / GitHub webhook concepts  
**Environment:** Linux
