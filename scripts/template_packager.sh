#!/usr/bin/env bash
set -euo pipefail

# Required environment variables
: "${BUCKET_NAME:?BUCKET_NAME is not set}"
: "${S3_PREFIX:?S3_PREFIX is not set}"

TEMPLATE_DIR="${TEMPLATE_DIR:-templates}"
MAIN_TEMPLATE="${TEMPLATE_DIR}/main.yaml"
AWS_REGION="${AWS_REGION:-us-east-1}"

# Create S3 bucket if it doesn't exist
if ! aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo "Creating bucket s3://${BUCKET_NAME}"
  if [[ "${AWS_REGION}" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "${BUCKET_NAME}" --region "${AWS_REGION}"
  else
    aws s3api create-bucket --bucket "${BUCKET_NAME}" --region "${AWS_REGION}" \
      --create-bucket-configuration LocationConstraint="${AWS_REGION}"
  fi
fi

echo "Uploading nested templates to s3://${BUCKET_NAME}/${S3_PREFIX}/"
aws s3 sync "${TEMPLATE_DIR}" "s3://${BUCKET_NAME}/${S3_PREFIX}/" \
  --exclude "main.yaml" \
  --include "*.yaml" --include "*.yml" --include "*.json"

echo "Rewriting TemplateURL paths in ${MAIN_TEMPLATE}"
S3_BASE="https://s3.amazonaws.com/${BUCKET_NAME}/${S3_PREFIX}"

while IFS= read -r line; do
  if [[ "${line}" =~ ^([[:space:]]*TemplateURL:[[:space:]]*)(.+)$ ]]; then
    indent="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[2]}"
    # Strip leading ./ or ../*/ and resolve to just the relative path
    clean_path=$(echo "${path}" | sed 's|^\./||; s|^\.\./[^/]*/||')
    echo "${indent}${S3_BASE}/${clean_path}"
  else
    echo "${line}"
  fi
done < "${MAIN_TEMPLATE}" > "${MAIN_TEMPLATE}.tmp" && mv "${MAIN_TEMPLATE}.tmp" "${MAIN_TEMPLATE}"

echo "Updated ${MAIN_TEMPLATE} with S3 URLs"
