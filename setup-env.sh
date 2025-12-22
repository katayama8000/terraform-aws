#!/bin/bash
# Load AWS credentials from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo "✓ AWS credentials loaded from .env"
  aws sts get-caller-identity --query 'Account' --output text > /dev/null 2>&1 && echo "✓ AWS authentication verified"
else
  echo "Error: .env file not found"
  exit 1
fi
