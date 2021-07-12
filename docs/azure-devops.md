# Azure DevOps
Azure DevOps can host git Repositories and run Pipelines the same way as GitHub Actions.

It is possible to combine GitHub and Azure Devops for git repository management and pipeline runs, e.g. having git repository on GitHub and pipeline in Azure DevOps or even call GitHub and Azure pipelines each other both directions - not recommended due to excessive complexity.

## Migrate to Azure DevOps
1. Fork the GitHub code to Azure DevOps.
2. Create Azure DevOps Pipeline similarly to [azure-pipeline.yaml](../.azure-devops/azure-pipelines.yaml) and configure pipelines Secrets as defined in Prerequsites for GitHub Actions approach.
3. Commit to the Repository hosted in Azure DevOps to trigger Azure DevOps pipeline.

## Explicit/Raw commands vs Azure DevOps Tasks.
Azure DevOps offers prebuilt abstractions `tasks` as wrappers around more explicit/raw `steps`. It is the same principle as `Github Actions` which also complement GitHub `steps`. Some `tasks` might not keep up with the lifecycle of the underlying commands and might be buggy. It is a question of personal preference and use cases:
- [Explicit approach](../.azure-devops/azure-pipelines.yaml).
- [Approach using Azure DevOps Tasks](../.azure-devops/azure-pipelines-using-tasks.yaml) - working sample to deploy only GCP resources. Requires to configure `Service connection` towards GCP in the Azure DevOps Project settings.

