# Bitbucket Pipelines Task: Azure Storage deploy

Task to deploy to [Microsoft Azure Storage](https://azure.microsoft.com/services/storage/).

Copy files and directories. Recursively copies new and updated files from the source local directory to the destination. Only creates folders in the destination if they contain one or more files.

## Usage

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
- task: atlassian/azure-storage-deploy:0.1.0
  environment:
    SOURCE: <string>
    DESTINATION: <string>
    DESTINATION_SAS_TOKEN: <string>
    # EXTRA_ARGS: <string>
```

## Parameters

| Environment                   | Usage                                                |
| ----------------------------- | ---------------------------------------------------- |
| SOURCE (*)                    |  The source of the files to copy (can be a path to a local file/directory or an Azure Storage URI) |
| SOURCE_SAS_TOKEN              |  A [SAS token](https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1) to be used for authenticating against the source (omit if the source is a local path) |
| DESTINATION (*)               |  The destination of the files to copy (can be a path to a local file/directory or an Azure Storage URI) |
| DESTINATION_SAS_TOKEN         |  A [SAS token](https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1) to be used for authenticating against the destination (omit if the destination is a local path) |
| EXTRA_ARGS                    |  Extra arguments to be passed to the azcopy command (see [azcopy docs](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux) for more details). |

_(*) = required parameter._

More info about parameters and values can be found in the Azure official documentation: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux

## Examples

Basic example:

```yaml
script:
  - task: atlassian/gcp-storage-deploy:0.1.0
    environment:
      SOURCE: "myfile"
      DESTINATION: "https://mystorageaccount.blob.core.windows.net/mycontainer/myfile"
      DESTINATION_SAS_TOKEN: "${AZURE_STORAGE_SAS_TOKEN}"
```

Advanced example: 
    
```yaml
script:
  - task: atlassian/gcp-storage-deploy:0.1.0
    environment:
      SOURCE: "mydirectory"
      DESTINATION: "https://mystorageaccount.blob.core.windows.net/mycontainer/mydirectory"
      DESTINATION_SAS_TOKEN: "${AZURE_STORAGE_SAS_TOKEN}"
      EXTRA_ARGS: "--exclude-older --preserve-last-modified-time"
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
