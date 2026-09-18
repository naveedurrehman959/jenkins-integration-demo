#!/bin/bash

echo "Jenkins Troubleshooting Guide"
echo "============================"

echo "1. Checking Jenkins Service..."
if sudo systemctl is-active --quiet jenkins; then
    echo "   ✓ Jenkins service is running"
else
    echo "   ✗ Jenkins service is not running"
    echo "   Fix: sudo systemctl start jenkins"
fi

echo ""
echo "2. Checking Java Installation..."
if java -version >/dev/null 2>&1; then
    echo "   ✓ Java is installed"
    java -version 2>&1 | head -1
else
    echo "   ✗ Java is not installed"
    echo "   Fix: sudo apt install openjdk-11-jdk"
fi

echo ""
echo "3. Checking Git Installation..."
if git --version >/dev/null 2>&1; then
    echo "   ✓ Git is installed"
    git --version
else
    echo "   ✗ Git is not installed"
    echo "   Fix: sudo apt install git"
fi

echo ""
echo "4. Checking Jenkins Port..."
if netstat -tlnp 2>/dev/null | grep -q ":8080"; then
    echo "   ✓ Jenkins is listening on port 8080"
else
    echo "   ✗ Jenkins is not listening on port 8080"
    echo "   Check: sudo netstat -tlnp | grep java"
fi

echo ""
echo "5. Checking Jenkins Logs..."
echo "   Recent Jenkins log entries:"
sudo tail -5 /var/log/jenkins/jenkins.log 2>/dev/null || echo "   Log file not accessible"

echo ""
echo "6. Checking Disk Space..."
df -h / | tail -1 | awk '{print "   Disk usage: " $5 " of " $2 " used"}'

echo ""
echo "Troubleshooting completed!"
