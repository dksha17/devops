1)clone the platform_devops repo (git clone git@dev-github.albertsons.com:albertsons/platform_devops.git)
2)change directory to terraform (cd platform_devops/terraform/VM/environments/dev)
3)update the subnet id where you want to create the VM (line 22) ex:
4)Need to export azure credentials tenant id, access key etc.
export ARM_TENANT_ID=""
export ARM_CLIENT_ID=""
export ARM_SUBSCRIPTION_ID=""
export ARM_CLIENT_SECRET=""

5)terraform plan, if plan is good then go ahead and apply the terraform (terraform apply)
6)terraform statefile is stored in the azure blob storage for central maintainance, which provides locking mechanism to the state file.
