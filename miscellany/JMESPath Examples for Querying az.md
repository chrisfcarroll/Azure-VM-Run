# JMESPath Examples for querying az ml

```
az vm list-skus --location uksouth --query '[?size]'
az vm list-skus --location uksouth --query '[?capabilities.name=="GPUs"]'
az vm list-skus --location uksouth --query '[?capabilities.VMDeploymentType=="IaaS"]'
az vm list-skus --location uksouth 
  --query 
    "[?resourceType=='virtualMachines'].{name:name,size:size,gpus:capabilities[?name=='GPUs']}|[?gpus].{name:name,size:size,gpus:gpus[0].to_number(value)}"

```

```
az ml environment list -w ml1 --query "[?contains(name,'GPU')]" --output table
az ml environment list -w ml1 --query "[?contains(name,'TensorFlow-2')]" --output table
az ml environment list -w ml1 --query "[?contains(name,'Tensor')].name
```