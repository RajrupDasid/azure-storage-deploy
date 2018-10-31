#!/usr/bin/env bats

# Test GCP storage, https://cloud.google.com/storage/

set -e

setup() {
  IMAGE_NAME=${DOCKERHUB_IMAGE}:${DOCKERHUB_TAG}
  RANDOM_NUMBER=$RANDOM
  LOCAL_DIR=tmp/azure-storage-${RANDOM_NUMBER}

  # clean up & create paths
  rm -rf $LOCAL_DIR
  mkdir -p $LOCAL_DIR

  echo "Pipelines is awesome!" > $LOCAL_DIR/deployment-${RANDOM_NUMBER}.txt
}

teardown() {
  # clean up
  rm -rf $LOCAL_DIR
}

@test "upload to GCP storage" {
  # execute tests
  run docker run \
    -e SOURCE="${LOCAL_DIR}" \
    -e DESTINATION="https://pipelinestasks.blob.core.windows.net/tasks-container/tasks-folder" \
    -e DESTINATION_SAS_TOKEN="${AZURE_STORAGE_SAS_TOKEN}" \
    -e EXTRA_ARGS="--recursive" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    $IMAGE_NAME

  [[ "${status}" == "0" ]]

  # verify
  run curl --silent "https://pipelinestasks.blob.core.windows.net/tasks-container/tasks-folder/deployment-${RANDOM_NUMBER}.txt"
  [[ "${status}" == "0" ]]
  [[ "${output}" == "Pipelines is awesome!" ]]
}
