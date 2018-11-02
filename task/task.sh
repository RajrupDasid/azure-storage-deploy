#!/bin/bash

# Deploy to Azure storage
#
# Required globals:
#   SOURCE
#   DESTINATION
#
# Optional globals:
#   SOURCE_SAS_TOKEN
#   DESTINATION_SAS_TOKEN
#   EXTRA_ARGS
#   DEBUG

source "$(dirname "$0")/common.sh"

enable_debug

# mandatory parameters
SOURCE=${SOURCE:?'SOURCE environment variable missing.'}
DESTINATION=${DESTINATION:?'DESTINATION environment variable missing.'}

debug SOURCE: "${SOURCE}"
debug DESTINATION: "${DESTINATION}"

ARGS_STRING="--quiet --source \"${SOURCE}\" --destination \"${DESTINATION}\""

if [ ! -z "${SOURCE_SAS_TOKEN}" ]; then
  ARGS_STRING="${ARGS_STRING} --source-sas \"${SOURCE_SAS_TOKEN}\""
fi

if [ ! -z "${DESTINATION_SAS_TOKEN}" ]; then
  ARGS_STRING="${ARGS_STRING} --dest-sas \"${DESTINATION_SAS_TOKEN}\""
fi

ARGS_STRING="${ARGS_STRING} ${EXTRA_ARGS:=""}"

debug ARGS_STRING: "${ARGS_STRING}"

info "Starting deployment to Azure storage..."

run azcopy ${ARGS_STRING}

if [ "${status}" -eq 0 ]; then
  success "Deployment successful."
else
  fail "Deployment failed."
fi
