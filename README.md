# Bitbucket Pipelines Pipe: Azure Storage deploy

Pipe to deploy to [Microsoft Azure Storage](https://azure.microsoft.com/services/storage/).
Copies files and directories to Azure Blob or File storage
using [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux).
Automatically adds the "--recursive" option if the source is a directory on the local filesystem.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
- pipe: atlassian/azure-storage-deploy:0.5.0
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
| DESTINATION (*)               |  The file copy destination. This will normally be a [Blob Resource URI](https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-containers--blobs--and-metadata#resource-uri-syntax) or [File Resource URI](https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-shares--directories--files--and-metadata#resource-uri-syntax) but it can alternatively be a path on the local filesystem where the pipe is executing. |
| DESTINATION_SAS_TOKEN         |  A [SAS token](https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1) for authenticating against the destination (not needed if the destination is a local path). |
| SOURCE_SAS_TOKEN              |  A [SAS token](https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1) for authenticating against the source (not needed in the usual case where the source is a local path). |
| EXTRA_ARGS                    |  Extra arguments to be passed to the azcopy command (see [azcopy docs](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux) for more details). |
| DEBUG                         |  Turn on extra debug information. Default: `false`. |

_(*) = required variable._

More info about parameters and values can be found in the Azure official documentation: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux

## Examples

### Basic example:

```yaml
script:
  - pipe: atlassian/azure-storage-deploy:0.5.0
    variables:
      SOURCE: 'myfile'
      DESTINATION: 'https://mystorageaccount.blob.core.windows.net/mycontainer/myfile'
      DESTINATION_SAS_TOKEN: ${AZURE_STORAGE_SAS_TOKEN}
```

### Advanced example: 
    
```yaml
script:
  - pipe: atlassian/azure-storage-deploy:0.5.0
    variables:
      SOURCE: 'mydirectory'
      DESTINATION: 'https://mystorageaccount.blob.core.windows.net/mycontainer/mydirectory'
      DESTINATION_SAS_TOKEN: ${AZURE_STORAGE_SAS_TOKEN}
      EXTRA_ARGS: '--exclude-older --preserve-last-modified-time'
      DEBUG: 'true'
```


## Support
If you’d like help with this pipe, or you have an issue or feature request, [let us know on Community][community].

If you’re reporting an issue, please include:

* the version of the pipe
* relevant logs and error messages
* steps to reproduce

## License
Copyright (c) 2018 Atlassian and others.
Apache 2.0 licensed, see [LICENSE.txt](LICENSE.txt) file.

[community]: https://community.atlassian.com/t5/forums/postpage/choose-node/true/interaction-style/qanda?add-tags=bitbucket-pipelines,pipes,azure
