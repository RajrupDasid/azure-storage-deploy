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
SOURCE=${SOURCE:?'SOURCE variable missing.'}
DESTINATION=${DESTINATION:?'DESTINATION variable missing.'}

debug SOURCE: "${SOURCE}"
debug DESTINATION: "${DESTINATION}"

ARGS_STRING="\"${SOURCE}"

if [ ! -z "${SOURCE_SAS_TOKEN}" ]; then
  ARGS_STRING="${ARGS_STRING}${SOURCE_SAS_TOKEN}"
fi

ARGS_STRING="${ARGS_STRING}\" \"${DESTINATION}"

if [ ! -z "${DESTINATION_SAS_TOKEN}" ]; then
  ARGS_STRING="${ARGS_STRING}${DESTINATION_SAS_TOKEN}"
fi

ARGS_STRING="${ARGS_STRING}\""

if [ -d "${SOURCE}" ]; then
  ARGS_STRING="${ARGS_STRING} --recursive=true"
fi

if [[ "${DEBUG}" == "true" ]]; then
  ARGS_STRING="${ARGS_STRING} --log-level=DEBUG"
fi

ARGS_STRING="${ARGS_STRING} ${EXTRA_ARGS:=""}"

debug ARGS_STRING: "${ARGS_STRING}"

info "Starting deployment to Azure storage..."

run azcopy cp ${ARGS_STRING}

if [ "${status}" -eq 0 ]; then
  success "Deployment successful."
else
  fail "Deployment failed."
fi
