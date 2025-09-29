#!/bin/bash

set -e

echo "🚀 Starting EC2 Stock Market deployment..."

cd terraform

echo "📦 Initializing Terraform..."
terraform init -input=false

echo "🏗️  Applying infrastructure..."
terraform apply -auto-approve

cd ../ansible

echo "⏳ Waiting for EC2 SSH availability..."

export ANSIBLE_HOST_KEY_CHECKING=False

until ansible ec2 -i inventory.ini -m ping >/dev/null 2>&1; do
  echo "🔄 Waiting for SSH..."
  sleep 5
done

echo "✅ EC2 is ready. Running Ansible playbook..."
ansible-playbook -i inventory.ini playbook.yml

echo "🎉 Deployment completed!"