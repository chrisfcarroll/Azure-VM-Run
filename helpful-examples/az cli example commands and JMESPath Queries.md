az cli Example Commands and JMESPath Queries
============================================

 

### List Available VM Configurations

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
az vm list-skus --location uksouth --query '[?size]'
az vm list-skus --location uksouth --query '[?capabilities.name=="GPUs"]'

az vm list-skus --location uksouth --query '[?capabilities.VMDeploymentType=="IaaS"]'

az vm list-skus --query "[?resourceType=='virtualMachines'].{name:name,size:size,gpus:capabilities[?name=='GPUs']}|[?gpus].{name:name,size:size,gpus:gpus[0].to_number(value)}"

az vm list-skus --all --query "[?resourceType=='virtualMachines'].{name:name,size:size,gpus:capabilities[?name=='GPUs']}|[?gpus].{name:name,size:size,gpus:gpus[0].to_number(value)}"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

### List Available VM Images

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
az vm image list --offer Ubuntu --all

az vm image list -p microsoft-ads --all --query "[?contains(offer,'data-science')]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

### Show and Accept Image Licenses by publisher,offer,plan

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
az vm image terms show --publisher microsoft-ads --offer linux-data-science-vm --plan Standard

az vm image terms accept --publisher microsoft-ads --offer linux-data-science-vm --plan Standard
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

### Show and Accept Image Licenses by specific Image Urn

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
az vm image terms show --urn microsoft-ads:linux-data-science-vm:linuxdsvm:20.08.06

az vm image terms accept --urn microsoft-ads:linux-data-science-vm:linuxdsvm:20.08.06
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

### List Available ML Python Environments

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
az ml environment list -w ml1 --query "[?contains(name,'GPU')]" --output table

az ml environment list -w ml1 --query "[?contains(name,'PyTorch-1.6')]" --output table

az ml environment list -w ml1 --query "[?contains(name,'Tensor')].name
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
