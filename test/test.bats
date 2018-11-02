#!/usr/bin/env bats

# Test Azure Storage

set -e

setup() {
  IMAGE_NAME=${DOCKERHUB_IMAGE}:${DOCKERHUB_TAG}
  RANDOM_NUMBER=$RANDOM
  LOCAL_DIR=tmp/azure-storage-${RANDOM_NUMBER}

  # clean up & create paths
  rm -rf $LOCAL_DIR
  mkdir -p $LOCAL_DIR/subdir

  echo "Pipelines is awesome!" > $LOCAL_DIR/subdir/deployment-${RANDOM_NUMBER}.txt
  echo "Not deployed" > $LOCAL_DIR/subdir/not-deployed-${RANDOM_NUMBER}.txt
}

teardown() {
  # clean up
  rm -rf $LOCAL_DIR
}

@test "upload to Azure Storage" {
  # execute tests
  run docker run \
    -e SOURCE="${LOCAL_DIR}" \
    -e DESTINATION="https://pipelinestasks.blob.core.windows.net/tasks-container/tasks-folder" \
    -e DESTINATION_SAS_TOKEN="${AZURE_STORAGE_SAS_TOKEN}" \
    -e EXTRA_ARGS='--include deployment-*' \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    $IMAGE_NAME

  [[ "${status}" == "0" ]]

  # verify
  run curl --silent "https://pipelinestasks.blob.core.windows.net/tasks-container/tasks-folder/subdir/deployment-${RANDOM_NUMBER}.txt"
  [[ "${status}" == "0" ]]
  [[ "${output}" == "Pipelines is awesome!" ]]

  run curl -s -o /dev/null -w "%{http_code}" "https://pipelinestasks.blob.core.windows.net/tasks-container/tasks-folder/subdir/not-deployed-${RANDOM_NUMBER}.txt"
  [[ "${status}" == "0" ]]
  [[ "${output}" == "404" ]]
}
