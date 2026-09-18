#!/bin/bash

echo "Jenkins Build Monitor"
echo "===================="
echo "Timestamp: $(date)"
echo ""

# Check Jenkins service status
echo "Jenkins Service Status:"
sudo systemctl status jenkins --no-pager -l
echo ""

# Check recent build logs (if available)
echo "Recent Jenkins Activity:"
if [ -d "/var/lib/jenkins/jobs" ]; then
    find /var/lib/jenkins/jobs -name "builds" -type d | head -5
fi
echo ""

# Check Git status in project
if [ -d "~/jenkins-integration-demo" ]; then
    cd ~/jenkins-integration-demo
    echo "Git Repository Status:"
    git status --porcelain
    echo "Latest commits:"
    git log --oneline -5
fi
