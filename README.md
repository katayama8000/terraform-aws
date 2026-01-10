# Terraform AWS

## Prerequisites

- AWS Account
- AWS CLI configured
- Terraform installed

## Setup

1. Copy `.env.local` to `.env` and fill in your AWS credentials:
```bash
cp .env.local .env
```

2. Edit `.env` with your AWS credentials:
```
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
AWS_DEFAULT_REGION=ap-northeast-1
```

## Commonly Used Commands

### Initialize Terraform
```bash
terraform init
```
Initialize the Terraform working directory. Downloads provider plugins and modules.

### Validate Configuration
```bash
terraform validate
```
Check whether the configuration is valid.

### Format Code
```bash
terraform fmt
```
Automatically format Terraform configuration files to a canonical format.

### Plan Changes
```bash
terraform plan
```
Show what changes Terraform will make to your infrastructure.

### Apply Changes
```bash
terraform apply
```
Apply the changes required to reach the desired state of the configuration.

### Apply with Auto-Approve
```bash
terraform apply -auto-approve
```
Apply changes without prompting for confirmation.

### Destroy Infrastructure
```bash
terraform destroy
```
Destroy all resources managed by this Terraform configuration.

### Show Current State
```bash
terraform show
```
Display the current state or a saved plan.

### List Resources
```bash
terraform state list
```
List all resources in the state file.

### Output Values
```bash
terraform output
```
Display output values from the state file.

### Refresh State
```bash
terraform refresh
```
Update the state file with real infrastructure.

## AWS CLI Commands

### Check AWS Identity
```bash
aws sts get-caller-identity
```
Verify which AWS account and user you're authenticated as.