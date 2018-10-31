set +x

IMAGE_NAME=${DOCKERHUB_IMAGE}:${DOCKERHUB_TAG}
RANDOM_NUMBER=$RANDOM
LOCAL_DIR=tmp/azure-storage-${RANDOM_NUMBER}

# clean up & create paths
rm -rf $LOCAL_DIR
mkdir -p $LOCAL_DIR

echo "Pipelines is awesome!" > $LOCAL_DIR/deployment-${RANDOM_NUMBER}.txt

echo IMAGE_NAME: $IMAGE_NAME
echo RANDOM_NUMBER: $RANDOM_NUMBER
echo LOCAL_DIR: $LOCAL_DIR
ls -al $LOCAL_DIR

docker run \
    -e SOURCE="${LOCAL_DIR}" \
    -e DESTINATION="https://pipelinestasks.blob.core.windows.net/tasks-container/tasks-folder" \
    -e DESTINATION_SAS_TOKEN="${AZURE_STORAGE_SAS_TOKEN}" \
    -e EXTRA_ARGS="--recursive" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    $IMAGE_NAME

