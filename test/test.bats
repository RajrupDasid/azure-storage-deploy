#!/usr/bin/env bats

setup() {
  DOCKER_IMAGE=${DOCKER_IMAGE:="test/azure-storage-deploy"}

  # generated
  RANDOM_NUMBER=$RANDOM

  # required globals - stored in Pipelines repository variables
  AZURE_APP_ID="${AZURE_APP_ID}"
  AZURE_PASSWORD="${AZURE_PASSWORD}"
  AZURE_TENANT_ID="${AZURE_TENANT_ID}"

  # locals - generated
  AZURE_RESOURCE_GROUP="bbci-pipes-test-infra-${RANDOM_NUMBER}"
  LOCAL_DIR="tmp/azure-storage-${RANDOM_NUMBER}"
  STORAGE_ACCOUNT_NAME="bbpipetest${RANDOM_NUMBER}"
  CONTAINER_NAME="test-container"
  SAS_TOKEN_EXPIRY=`date -d "30 minutes" '+%Y-%m-%dT%H:%M:%SZ'` # 30 minutes from now
  PERMISSIONS="rw"

  # locals - fixed
  LOCATION="CentralUS"
  SKU="Standard_LRS"

  echo "Building image..."
  docker build -t ${DOCKER_IMAGE}:0.1.0 .

  echo "Clean up and create local paths and files"
  rm -rf $LOCAL_DIR
  mkdir -p $LOCAL_DIR/subdir

  echo "Pipelines is awesome!" > $LOCAL_DIR/subdir/deployment-${RANDOM_NUMBER}.txt
  echo "Not deployed" > $LOCAL_DIR/subdir/not-deployed-${RANDOM_NUMBER}.txt

  echo "Create required Azure resources"
  az login --service-principal --username ${AZURE_APP_ID} --password ${AZURE_PASSWORD} --tenant ${AZURE_TENANT_ID}
  az group create --name ${AZURE_RESOURCE_GROUP} --location ${LOCATION}
  az storage account create --name ${STORAGE_ACCOUNT_NAME} --resource-group ${AZURE_RESOURCE_GROUP} --location ${LOCATION} --sku ${SKU}
  az storage container create --name ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT_NAME}

  # required globals - generated
  DESTINATION="https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}"

  # optional globals - generated
  DESTINATION_SAS_TOKEN="?$(az storage container generate-sas --name ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --expiry ${SAS_TOKEN_EXPIRY} --permissions ${PERMISSIONS} | sed 's/["\t]//g')"
}

teardown() {
  echo "Clean up local paths and files"
  rm -rf $LOCAL_DIR

  echo "Clean up Resource Group"
  az group delete -n ${AZURE_RESOURCE_GROUP} --yes
}


@test "upload file to Azure Storage" {

  echo "Run test"
  run docker run \
    -e SOURCE="${LOCAL_DIR}/subdir/deployment-${RANDOM_NUMBER}.txt" \
    -e DESTINATION="${DESTINATION}/subdir/" \
    -e DESTINATION_SAS_TOKEN="${DESTINATION_SAS_TOKEN}" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ${DOCKER_IMAGE}:0.1.0

  [[ "${status}" == "0" ]]

  # verify
  run curl --silent "${DESTINATION}/subdir/deployment-${RANDOM_NUMBER}.txt${DESTINATION_SAS_TOKEN}"

  [[ "${status}" == "0" ]]
  [[ "${output}" == "Pipelines is awesome!" ]]

  run curl -s -o /dev/null -w "%{http_code}" "${DESTINATION}/subdir/not-deployed-${RANDOM_NUMBER}.txt${DESTINATION_SAS_TOKEN}"
  [[ "${status}" == "0" ]]
  [[ "${output}" == "404" ]]
}


@test "upload directory to Azure Storage" {

  echo "Run test"
  run docker run \
    -e SOURCE="${LOCAL_DIR}/subdir/*" \
    -e DESTINATION="${DESTINATION}/subdir/" \
    -e DESTINATION_SAS_TOKEN="${DESTINATION_SAS_TOKEN}" \
    -e EXTRA_ARGS="--recursive" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ${DOCKER_IMAGE}:0.1.0

  [[ "${status}" == "0" ]]

  # verify
  run curl --silent "${DESTINATION}/subdir/deployment-${RANDOM_NUMBER}.txt${DESTINATION_SAS_TOKEN}"

  [[ "${status}" == "0" ]]
  [[ "${output}" == "Pipelines is awesome!" ]]
}


@test "copy file to another container Azure Storage" {

  echo "setup test infrastructure"
  SOURCE_CONTAINER_NAME="test-container-2"
  az storage container create --name ${SOURCE_CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT_NAME}
  SOURCE="https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${SOURCE_CONTAINER_NAME}"
  SOURCE_SAS_TOKEN="?$(az storage container generate-sas --name ${SOURCE_CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --expiry ${SAS_TOKEN_EXPIRY} --permissions ${PERMISSIONS} | sed 's/["\t]//g')"


  echo "Upload file to the source container"
  run docker run \
    -e SOURCE="${LOCAL_DIR}/subdir/deployment-${RANDOM_NUMBER}.txt" \
    -e DESTINATION="${SOURCE}/subdir/" \
    -e DESTINATION_SAS_TOKEN="${SOURCE_SAS_TOKEN}" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ${DOCKER_IMAGE}:0.1.0

  [[ "${status}" == "0" ]]


  echo "Run test"
  run docker run \
    -e SOURCE="${SOURCE}/subdir/deployment-${RANDOM_NUMBER}.txt" \
    -e SOURCE_SAS_TOKEN="${SOURCE_SAS_TOKEN}" \
    -e DESTINATION="${DESTINATION}/subdir/deployment-${RANDOM_NUMBER}.txt" \
    -e DESTINATION_SAS_TOKEN="${DESTINATION_SAS_TOKEN}" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ${DOCKER_IMAGE}:0.1.0

  echo $output

  [[ "${status}" == "0" ]]

  # verify
  run curl --silent "${DESTINATION}/subdir/deployment-${RANDOM_NUMBER}.txt${DESTINATION_SAS_TOKEN}"

  [[ "${status}" == "0" ]]
  [[ "${output}" == "Pipelines is awesome!" ]]
}


