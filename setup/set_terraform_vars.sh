#!/bin/bash
# Setup before running install.sh
# Purpose is to create the terraform.tfvars file

set -eEuo pipefail

PARSERS=""
for PARSER in ${GIT_SYSTEM}; do
    if [ "${PARSERS}" == "" ]; then
        PARSERS="\"${PARSER}\""
    else
        PARSERS+=",\"${PARSER}\""
    fi
done

cat > terraform.tfvars <<EOF
google_project_id = "${FOURKEYS_PROJECT}"
google_region = "${FOURKEYS_REGION}"
bigquery_region = "${BIGQUERY_REGION}"
parsers = [${PARSERS}]
EOF

echo "Terraform variables set"
cat terraform.tfvars
