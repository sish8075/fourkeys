# Setup before running install.sh
# Purpose is to set the following variables:
#   GIT_SYSTEM
#   CICD_SYSTEM
#   PARENT_PROJECT
#   FOURKEYS_PROJECT
#   FOURKEYS_REGION
#   BIGQUERY_REGION
#   GENERATE_DATA
# VCS available are GitHub, GitLab, Other (see docs for setting up 'Other' system)
# CI/CD available are CloudBuild, Tekton, CircleCI, GitLab, GitHub, Other

set -eEuo pipefail

# Setting variables
GIT_SYSTEM="github"
CICD_SYSTEM="github"
PARENT_PROJECT=$GCP_PROJECT_ID # project ID for project used for billing
FOURKEYS_PROJECT=$GCP_PROJECT_ID # project ID for Four Keys installation
FOURKEYS_REGION="us-east1" # region for Four Keys resources
BIGQUERY_REGION="US" # location for Four Keys BQ resources, US or EU
GENERATE_DATA="no"

CLEAN="false"
if [[ ${CLEAN} == 'true' ]]
then
    # purge all local terraform state
    rm -rf .terraform* *.containerbuild.log terraform.tfstate* terraform.tfvars
fi

PARSERS=""
for PARSER in ${GIT_SYSTEM}; do
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

printf "\n"
echo "••••••••🔑••🔑••🔑••🔑••••••••"
printf "starting Four Keys setup…\n\n"

#terraform init
#source install.sh
