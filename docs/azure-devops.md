# Azure DevOps
Azure DevOps can host git Repositories and run Pipelines the same way as GitHub Actions. Mixing both approaches is possible, however introduces excessive complexity. E.g. GitHub Action can trigger Azure DevOps Pipeline.

## Migrate to Azure DevOps
1. Fork the GitHub code to Azure DevOps.
2. Create Azure DevOps Pipeline out of [azure-pipeline.yaml](.azure-devops/azure-pipelines.yaml).
3. Commit to the Repository hosted in Azure DevOps to run Azure DevOps pipeline.

