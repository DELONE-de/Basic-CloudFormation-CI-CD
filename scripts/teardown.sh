#!/usr/bin/env bash
set -euo pipefail

: "${STACK_NAME:?STACK_NAME is not set}"

echo "Deleting stack '${STACK_NAME}'..."
aws cloudformation delete-stack --stack-name "${STACK_NAME}"

echo "Waiting for stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name "${STACK_NAME}"

echo "Stack '${STACK_NAME}' deleted."
