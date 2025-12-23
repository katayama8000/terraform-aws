#!/bin/bash
# Load AWS credentials from .env file
# Usage: source setup-env.sh (or . setup-env.sh)

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo "✓ AWS credentials loaded from .env"
  
  if aws sts get-caller-identity --query 'Account' --output text > /dev/null 2>&1; then
    echo "✓ AWS authentication verified"
    echo "Account: $(aws sts get-caller-identity --query 'Account' --output text)"
    echo "Region: $AWS_DEFAULT_REGION"
  else
    echo "✗ AWS authentication failed"
    return 1
  fi
else
  echo "Error: .env file not found"
  return 1
fi
