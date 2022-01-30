# Presentation

Click this link for presentation https://kaushikbishnu.github.io/ghost-nordcloud/

# Development

### This POC is using Terraform Cloud 
>I am using  for running terrafomrm scripts.
Terraform Cloud does not supprt -var-file argument.
It automatically takes variables form *.auto.tfvars files.
Hence I kept only one tfvars file. Ideally I will create a directory structure for supplying {env}.tfvars


### Folder structure options and naming conventions for this project

    
    ├── [.ssh]                          # ssh keystore 
    ├── [modules]                       # terraform modules for IAC 
        ├── [k8s]
            ├── main.tf
            ├── output.tf
            ├── variables.tf
        ├── [keyvault]
            ├── ...    
        ├── [mysql]
            ├── ...
        ├── [storage_account]
            ├── ...                
    ├── [scripts]                       # startup script for Terraform Cloud
    ├── [terraform.d]                   # terraform cloud generated files
    ├── backend.tf                      
    ├── dev.auto.tfvars                 # tfvars file for terrafomr cloud
    ├── main.tf
    ├── providers.tf
    ├── variables.tf
