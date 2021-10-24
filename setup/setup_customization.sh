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

# This script configures installation variables, then invokes `install.sh`

set -eEuo pipefail

# PARSE INPUTS
CLEAN="false"
AUTO="false"
FOURKEYS_PROJECT="" # project ID for Four Keys installation, provided as parameter
FOURKEYS_REGION="us-east1" # region for Four Keys resources
BIGQUERY_REGION="US" # location for Four Keys BQ resources, US or EU

for i in "$@"
do
  case $i in
    -c | --clean ) CLEAN="true"; shift;;
    -a | --auto ) AUTO="true"; shift;;
    -p | --project ) FOURKEYS_PROJECT=$2; shift 2;;
    -h | --help ) echo "Usage: ./setup.sh [--clean] [--auto] --project"; exit 0; shift;;
    *) ;; # unknown option
  esac
done

PARENT_PROJECT=$FOURKEYS_PROJECT

if [[ ${AUTO} == 'true' ]]
then
    # populate setup variables (for use in testing/dev)
    git_system_id=2 # sets git system to GitHub
    cicd_system_id=5 # sets cicd system to GitHub
    generate_mock_data=n # dont want to genereate mock data
    CLEAN='true'
else
    read -p "Which version control system are you using? 
    (1) GitLab
    (2) GitHub
    (3) Other

    Enter a selection (1 - 3): " git_system_id

    read -p "
    Which CI/CD system are you using? 
    (1) Cloud Build
    (2) Tekton
    (3) GitLab
    (4) CircleCI
    (5) GitHub
    (6) Other

    Enter a selection (1 - 6): " cicd_system_id

    printf "\n"

    read -p "Would you like to generate mock data? (y/N): " generate_mock_data
    generate_mock_data=${generate_mock_data:-no}
fi

if [[ ${CLEAN} == 'true' ]]
then
    # purge all local terraform state
    rm -rf .terraform* *.containerbuild.log terraform.tfstate* terraform.tfvars
fi

printf "\n"

GIT_SYSTEM=""
CICD_SYSTEM=""

case $git_system_id in
    1) GIT_SYSTEM="gitlab" ;;
    2) GIT_SYSTEM="github" ;;
    *) echo "Please see the documentation to learn how to extend to VCS sources other than GitHub or GitLab"
esac

case $cicd_system_id in
    1) CICD_SYSTEM="cloud-build" ;;
    2) CICD_SYSTEM="tekton" ;;
    3) CICD_SYSTEM="gitlab" ;;
    4) CICD_SYSTEM="circleci" ;;
    5) CICD_SYSTEM="github" ;;
    *) echo "Please see the documentation to learn how to extend to CI/CD sources other than Cloud Build, Tekton, GitLab, CircleCI or GitHub."
esac

if [ $generate_mock_data == "y" ]; then
    GENERATE_DATA="yes"
else
    GENERATE_DATA="no"
fi

PARSERS=""
for PARSER in ${GIT_SYSTEM} ${CICD_SYSTEM}; do
    if [ "${PARSERS}" == "" ]; then
        PARSERS="\"${PARSER}\""
    else
        PARSERS+=",\"${PARSER}\""
    fi
done

# create a tfvars file
cat > terraform.tfvars <<EOF
google_project_id = "${FOURKEYS_PROJECT}"
google_region = "${FOURKEYS_REGION}"
bigquery_region = "${BIGQUERY_REGION}"
parsers = [${PARSERS}]
EOF

echo "••••••••🔑••🔑••🔑••🔑••••••••"
printf "starting Four Keys setup…\n\n"

#terraform init
# run instal.sh in current shell
#source install.sh 