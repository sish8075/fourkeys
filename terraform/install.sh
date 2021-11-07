#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script installs Four Keys; it requires several environment
# variables and terraform variables to be set; to set them interactively 
# and then launch installation, run `setup.sh`.

    # REQUIRED ENVIRONMENT VARIABLES
    # GIT_SYSTEM (e.g. "github")
    # CICD_SYSTEM (e.g. "cloud-build")
    # PARENT_PROJECT (the project that will orchestrate the install)
    # FOURKEYS_PROJECT (the project to install Four Keys to)
    # FOURKEYS_REGION (GCP region for cloud resources)
    # BIGQUERY_REGION (location for BigQuery resources)
    # GENERATE_DATA ["yes"|"no"]

    # REQUIRED TERRAFORM VARIABLES
    # google_project_id (FOURKEYS_PROJECT)
    # google_region (FOURKEYS_REGION)
    # bigquery_region (BIGQUERY_REGION)
    # parsers [(list of VCS and CICD parsers to install)]

set -eEuo pipefail

# color formatting shortcuts
export GREEN="\033[0;32m"
export NOCOLOR="\033[0m"

PARENT_PROJECTNUM=$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')
FOURKEYS_PROJECTNUM=$(gcloud projects describe ${FOURKEYS_PROJECT} --format='value(projectNumber)')

if [ $GENERATE_DATA == "yes" ]; then
    
    TOKEN=""

    # Create an identity token if running in cloudbuild tests
    if [[ "$(gcloud config get-value account)" == "${PARENT_PROJECTNUM}@cloudbuild.gserviceaccount.com" ]]
    then
    TOKEN=$(curl -X POST -H "content-type: application/json" \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -d "{\"audience\": \"$(terraform output -raw event_handler_endpoint)\"}" \
        "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/fourkeys@${FOURKEYS_PROJECT}.iam.gserviceaccount.com:generateIdToken" | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
    fi
    
    echo "generating data…"
    WEBHOOK=$(terraform output -raw event_handler_endpoint) SECRET=$(terraform output -raw event_handler_secret) TOKEN=${TOKEN} python3 ../data_generator/generate_data.py --vc_system=${GIT_SYSTEM}
fi

echo "••••••••🔑••🔑••🔑••🔑••••••••"
echo "configuring Grafana dashboard…"
DASHBOARD_URL="$(terraform output -raw dashboard_endpoint)/d/yVtwoQ4nk/four-keys?orgId=1"

echo -e "Please visit ${GREEN}$DASHBOARD_URL${NOCOLOR} to view your data in the dashboard template."

if [[ ! -z "$CICD_SYSTEM" ]]; then
    echo "••••••••🔑••🔑••🔑••🔑••••••••"
    echo 'Setup complete! Run the following commands to get values needed to configure VCS webhook:'
    echo -e "➡️ Webhook URL: ${GREEN}echo \$(terraform output -raw event_handler_endpoint)${NOCOLOR}"
    echo -e "➡️ Secret: ${GREEN}echo \$(terraform output -raw event_handler_secret)${NOCOLOR}"
fi
