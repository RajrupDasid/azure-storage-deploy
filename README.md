# Bitbucket Pipelines Task: Azure Storage deploy

Task to deploy to [Microsoft Azure Storage](https://azure.microsoft.com/services/storage/).

Copies files and directories to Azure Blob or File storage
using [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux).
Automatically adds the "--recursive" option if the source is a directory on the local filesystem.

## Usage

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
- task: atlassian/azure-storage-deploy:0.4.0
  environment:
    SOURCE: "<string>"
    DESTINATION: "<string>"
    DESTINATION_SAS_TOKEN: "${AZURE_STORAGE_SAS_TOKEN}"
    # EXTRA_ARGS: "<string>"
    # DEBUG: "<boolean>"
```

## Parameters

| Environment                   | Usage                                                |
| ----------------------------- | ---------------------------------------------------- |
| SOURCE (*)                    |  The source of the files to copy. This will normally be the path to a file or directory on the local filesystem where the task is executing but it can alternatively be an Azure Storage resource URI. |
| DESTINATION (*)               |  The file copy destination. This will normally be a [Blob Resource URI](https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-containers--blobs--and-metadata#resource-uri-syntax) or [File Resource URI](https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-shares--directories--files--and-metadata#resource-uri-syntax) but it can alternatively be a path on the local filesystem where the task is executing. |
| DESTINATION_SAS_TOKEN         |  A [SAS token](https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1) for authenticating against the destination (not needed if the destination is a local path). |
| SOURCE_SAS_TOKEN              |  A [SAS token](https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1) for authenticating against the source (not needed in the usual case where the source is a local path). |
| EXTRA_ARGS                    |  Extra arguments to be passed to the azcopy command (see [azcopy docs](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux) for more details). |
| DEBUG                         |  If equal to "true", outputs extra information to help debug issues running this task. |

_(*) = required parameter._

More info about parameters and values can be found in the Azure official documentation: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux

## Examples

Basic example:

```yaml
script:
  - task: atlassian/azure-storage-deploy:0.4.0
    environment:
      SOURCE: "myfile"
      DESTINATION: "https://mystorageaccount.blob.core.windows.net/mycontainer/myfile"
      DESTINATION_SAS_TOKEN: "${AZURE_STORAGE_SAS_TOKEN}"
```

Advanced example: 
    
```yaml
script:
  - task: atlassian/azure-storage-deploy:0.4.0
    environment:
      SOURCE: "mydirectory"
      DESTINATION: "https://mystorageaccount.blob.core.windows.net/mycontainer/mydirectory"
      DESTINATION_SAS_TOKEN: "${AZURE_STORAGE_SAS_TOKEN}"
      EXTRA_ARGS: "--exclude-older --preserve-last-modified-time"
      DEBUG: "true"
```

## Bugs
Issues, bugs and feature requests can be reported via the [Bitbucket Cloud public issue tracker][sitemaster].

When reporting bugs or issues, please provide:

* The version of the task
* Relevant logs and error messages
* Steps to reproduce

## License
Copyright (c) 2018 Atlassian and others.
Apache 2.0 licensed, see [LICENSE.txt](LICENSE.txt) file.

[sitemaster]: https://bitbucket.org/site/master
