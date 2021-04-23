# Bitbucket Pipelines Pipe: Azure Storage Deploy

Pipe to deploy to [Microsoft Azure Storage](https://azure.microsoft.com/services/storage/).
Copies files and directories to Azure Blob or File storage
using [AzCopy][azcopy docs].
Automatically adds the "--recursive" option if the source is a directory on the local filesystem.

Note: This pipe was forked from https://bitbucket.org/microsoft/azure-storage-deploy for future maintenance purposes.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
- pipe: atlassian/azure-storage-deploy:1.0.2
  variables:
    SOURCE: '<string>'
    DESTINATION: '<string>'
    # DESTINATION_SAS_TOKEN: '<string>' # Optional.
    # SOURCE_SAS_TOKEN: '<string>' # Optional.
    # EXTRA_ARGS: '<string>' # Optional.
    # DEBUG: '<boolean>' # Optional.
```

## Variables

| Variable                   | Usage                                                |
| ----------------------------- | ---------------------------------------------------- |
| SOURCE (*)                    |  The source of the files to copy. This will normally be the path to a file or directory on the local filesystem where the pipe is executing but it can alternatively be an Azure Storage resource URI. |
| DESTINATION (*)               |  The file copy destination. This will normally be a [Blob Resource URI][Blob Resource URI] or [File Resource URI][File Resource URI] but it can alternatively be a path on the local filesystem where the pipe is executing. |
| DESTINATION_SAS_TOKEN         |  A [SAS(Shared Access Signature) token][SAS token] for authenticating against the destination (not needed if the destination is a local path). |
| SOURCE_SAS_TOKEN              |  A [SAS(Shared Access Signature) token][SAS token] for authenticating against the source (not needed in the usual case where the source is a local path). |
| EXTRA_ARGS                    |  Extra arguments to be passed to the azcopy command (see [azcopy docs][azcopy docs] for more details). |
| DEBUG                         |  Turn on extra debug information. Default: `false`. |

_(*) = required variable._


More info about parameters and values can be found in the Azure official documentation: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux


## Prerequisites
* An IAM user is configured with sufficient permissions to perform a deployment of your data to the Azure storage.
* You have configured the [Azure storage account][Azure storage account] and environment.
* You have configured the [SAS(Shared Access Signature) token][SAS token] for your destination or source.


## Examples

### Basic example
Upload a file to Azure Storage:

```yaml
script:
  - pipe: atlassian/azure-storage-deploy:1.0.2
    variables:
      SOURCE: 'myfile'
      DESTINATION: 'https://mystorageaccount.blob.core.windows.net/mycontainer/myfile'
      DESTINATION_SAS_TOKEN: $AZURE_STORAGE_SAS_TOKEN
```

Upload a directory to Azure Storage:
```yaml
script:
  - pipe: atlassian/azure-storage-deploy:1.0.2
    variables:
      SOURCE: 'mydirectory'
      DESTINATION: 'https://mystorageaccount.blob.core.windows.net/mycontainer/'
      DESTINATION_SAS_TOKEN: $AZURE_STORAGE_SAS_TOKEN
      DEBUG: 'true'
```

### Advanced example

Upload a directory to Azure Storage with $web param:
```yaml
script:
  - pipe: atlassian/azure-storage-deploy:1.0.2
    variables:
      SOURCE: 'mydirectory'
      DESTINATION: 'https://mystorageaccount.blob.core.windows.net/\\\$web'
      DESTINATION_SAS_TOKEN: $AZURE_STORAGE_SAS_TOKEN
```


Upload the contents of a directory without copying the containing directory itself:
```yaml
script:
  - pipe: atlassian/azure-storage-deploy:1.0.2
    variables:
      SOURCE: 'mydirectory/*'
      DESTINATION: 'https://mystorageaccount.blob.core.windows.net/mycontainer/'
      DESTINATION_SAS_TOKEN: $AZURE_STORAGE_SAS_TOKEN
      DEBUG: 'true'
```

Upload a directory and prevent overwrite the conflicting files/blobs at the destination:
```yaml
script:
  - pipe: atlassian/azure-storage-deploy:1.0.2
    variables:
      SOURCE: 'mydirectory'
      DESTINATION: 'https://mystorageaccount.blob.core.windows.net/mycontainer/mydirectory'
      DESTINATION_SAS_TOKEN: $AZURE_STORAGE_SAS_TOKEN
      EXTRA_ARGS: '--overwrite=false'
      DEBUG: 'true'
```

## Support
If you’d like help with this pipe, or you have an issue or feature request, [let us know on Community][community].

If you’re reporting an issue, please include:

- the version of the pipe
- relevant logs and error messages
- steps to reproduce


## License
Copyright (c) 2020 Atlassian and others.
Apache 2.0 licensed, see [LICENSE](LICENSE) file.


[community]: https://community.atlassian.com/t5/forums/postpage/board-id/bitbucket-pipelines-questions?add-tags=pipes,azure,storage

[azcopy docs]: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux
[Blob Resource URI]: https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-containers--blobs--and-metadata#resource-uri-syntax
[File Resource URI]: https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-shares--directories--files--and-metadata#resource-uri-syntax
[Azure storage account]: https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account
[SAS token]: https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1