#!/usr/bin/env bash
set -euo pipefail

# Required environment variables
: "${STACK_NAME:?STACK_NAME is not set}"

MAIN_TEMPLATE="${TEMPLATE_DIR:-templates}/main.yaml"
ENV="${ENVIRONMENT:-dev}"
CAPABILITIES="CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND"

echo "Deploying stack '${STACK_NAME}' using ${MAIN_TEMPLATE}"

aws cloudformation deploy \
  --template-file "${MAIN_TEMPLATE}" \
  --stack-name "${STACK_NAME}" \
  --capabilities ${CAPABILITIES} \
  --no-fail-on-empty-changeset \
  --tags Environment="${ENV}"

echo "Fetching stack outputs..."
aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs" \
  --output table
