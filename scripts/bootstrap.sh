#!/bin/bash
# One-time EC2 provisioning. Run as root (User Data) or: sudo bash scripts/bootstrap.sh
# After this completes, see DEPLOYMENT.md for the remaining one-time manual steps.
set -euo pipefail

echo "=== Updating system ==="
apt update && apt upgrade -y

echo "=== Installing Docker ==="
apt install -y docker.io docker-compose-v2
usermod -aG docker ubuntu

echo "=== Installing Nginx + Certbot ==="
apt install -y nginx certbot python3-certbot-nginx
systemctl enable nginx

echo "=== Installing Node 20 ==="
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

echo "=== Creating directories ==="
mkdir -p /app
chown ubuntu:ubuntu /app
mkdir -p /var/www/magic-nugger/web-app

echo "=== Bootstrap complete ==="
echo "See DEPLOYMENT.md for remaining one-time steps (nginx config, certbot, GitHub secrets)."
