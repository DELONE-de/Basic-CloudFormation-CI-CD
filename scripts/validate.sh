#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_DIR="${TEMPLATE_DIR:-templates}"
FAILED=0

echo "Validating CloudFormation templates in ${TEMPLATE_DIR}/"

while IFS= read -r -d '' template; do
  echo -n "  Validating ${template}... "
  if aws cloudformation validate-template \
      --template-body "file://${template}" \
      --output text > /dev/null 2>&1; then
    echo "OK"
  else
    echo "FAILED"
    FAILED=$((FAILED + 1))
  fi
done < <(find "${TEMPLATE_DIR}" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) -print0)

if [[ ${FAILED} -gt 0 ]]; then
  echo "Validation failed for ${FAILED} template(s)."
  exit 1
fi

echo "All templates validated successfully."
