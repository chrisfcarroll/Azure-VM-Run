#! /usr/bin/env pwsh -NoProfile
# ----------------------------------------------------------------------------
# The following line is deliberately left blank for powershell help parsing.

<#
.Synopsis
Azure-ml-setup.ps1 will create the nested sequence of Azure resources needed to run a script on 
an Azure ML computetarget. 

.Description
- The script is based on the steps at 
  https://docs.microsoft.com/en-us/azure/machine-learning/tutorial-train-deploy-model-cli

- You can use the script to the very end, or just use parts of it.

- Required: You must already have an Azure Subscription with permissions to create 
  resources. If you don't have one, you can get a new one for free in about 
  10 minutes at https://azure.com

----------------------------------------------------------------------------
Resources Created

[Azure Subscription]
  └── ResourceGroup (at a location)
      └── WorkSpace
          ├── Dataset
          ├── Computetarget (with a vmSize)
          └── Experiment
              └── runconfig (which references Dataset & Computetarget)

As you can see, the Workspace is the primary Container. 
- Keeping an empty WorkSpace alive costs about `$1 per day.
- To create and destroy a workspace each time you start work typically 
  takes a couple of minutes, and that is the first part of what this 
  script automates.

----------------------------------------------------------------------------
The Steps

1. Install az cli tool & ml extensions

2. All resources are 'kept' together in a ResourceGroup. A ResourceGroup is 
just a management convenience, tied to a location, but costing nothing.

3. In the resourceGroup, you must create a Workspace. This will allocate
some storage, and an unused workspace will cost you around `$1 per day. It
may take a couple of minutes to create, and slightly less time to delete.

4. Within the workspace, you create compute instances or compute clusters. 
Clusters have the advantage they can auto-scale down to 0 nodes–i.e. no cost—
when idle.

5. Attach a local folder on your desktop to the workspace.

6. Define a dataset

7. Create a runconfig referencing your script, dataset, and computetarget

8. Run the runconfig

--------------------------------------------------------------------------
Not covered by this script:
9. Attach an Azure blob container as a Datastore for large datasets
10. Upload files to a Datastore
11. Scaffold and register Environments
For these steps you may want an example or a tutorial, not a script.
----------------------------------------------------------------------------

Usage:

$commandName
    [[-resourceGroupName] <string>] [[-location] <string>]
    [[-workspaceName] <string>] 
    [[-computeTargetName] <string>] [[-computeTargetSize] <string>] 
    [[-experimentName] <string>] 
    [[-datasetDefinitionFile] <string>]
#>
Param(
  [string]$resourceGroupName,
  [string]$workspaceName,
  [string]$computeTargetName,
  [ValidateSet('nc6','nc12','nc24','nc6v3','nc12v3','nc24v3','nc6promo','nc12promo','nc24promo')]
    [string]$computeTargetSize='nc6',
  [string]$experimentName= (Split-Path (Get-Location) -Leaf),
  [ValidateScript({Test-Path $_ -PathType 'Leaf'})][string]$datasetDefinitionFile,
  [string]$location,
  [switch]$help
)
# ----------------------------------------------------------------------------
function Ask-YesNo($msg){return ($Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -eq 0)}
function Ask-YesElseThrow($msg){
  if($Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -ne 0){throw "Halted because you said No"}
}
# ----------------------------------------------------------------------------
if((-not $resourceGroupName -and -not $workspaceName) -or $help)
{
  Get-Help $PSCommandPath
  exit
}

# ----------------------------------------------------------------------------
"
1. Check az CLI is installed and ensure the az Machine Learning CLI extension is installed"
$azcli=(Get-Command az -ErrorAction SilentlyContinue)
if($azcli){
  "✅ Found at " + $azcli.Path
}else{
  Start-Process "https://www.bing.com/search?q=install+az+cli+site:microsoft.com"
  throw "az cli not found in path. 
        Find installation instructions via https://www.bing.com/search?q=install+az+cli+site:microsoft.com
        Having installed the CLI, don't forget to az login to confirm you can connect to your subscription."
}
az extension add -n azure-cli-ml
if($?){
  "✅ OK"
}else{
  Start-Process "https://www.bing.com/search?q=az+cli+install+extension+ml+failed"
  throw "Failed when adding extension azure-cli-ml. Not sure where to go from here."
}

# ----------------------------------------------------------------------------
"
2. Choose or Create a ResourceGroup $resourceGroupName"
if($resourceGroupName ){
  "Looking for existing resource group called $resourceGroupName ..."
  az group show --output table --name $resourceGroupName
  if($?){
    "✅ OK"    
  }elseif($location){
      "... none found.

      2.1 Create a new ResourceGroup $resourceGroupName in location $($location)? 
      (Creating a resource group is free and usually takes less than a minute)"
      Ask-YesElseThrow
      az group create --name $resourceGroupName --location $location
      if(-not $?){throw "failed at az group create --name $resourceGroupName --location $location"}
  }else{
    write-warning "
    To create a new ResourceGroup, you must also specify a location, for instance

    $commandName $resourceGroupName $workspaceName -location uksouth

    Halted at step 2. Choose or Create a ResourceGroup.
    "
    exit
  }
}else{
  "
  You current have these Resource Groups
  "
  az group list --output table
  "
  Use an existing group by specifying -resourceGroupName, or else specify 
  both -resourceGroupName and -location to create a new ResourceGroup.
  (ResourceGroups are free).

  "
  write-warning "Halted at step 2. Choose or Create a ResourceGroup.
  "
  exit
}

# ----------------------------------------------------------------------------

"
3. Choose or Create a Workspace $workspaceName"

if($workspaceName){
  "Looking for existing workspace called $workspaceName ..."
  az ml workspace show --workspace-name $workspaceName --resource-group $resourceGroupName `
        --output table --query "{name:name,resourceGroup:resourceGroup,location:location}"
  if(-not $?){
    "... none found.

    3.1 Create a new Workspace $workspaceName in ResourceGroup $($resourceGroupName)?
    "
    write-warning "(An unused workspace may cost you about a `$1 per day for storage)
    "
    Ask-YesElseThrow 
    "
    Please wait, this can typically take 2 or 3 minutes ..."
    az ml workspace create --workspace-name $workspaceName --resource-group $resourceGroupName
    if(-not $?){throw "failed at az ml workspace create --workspace-name $workspaceName --resource-group $resourceGroupName"}
  }
}else{
  "
  You current have these Workspaces:
  "
  az ml workspace list --output table --query "[].{ResourceGroup:resourceGroup,Name:workspaceName}"
  "
  Use an existing workspace by specifying -workspaceName, or else specify 
  both -workspaceName and -resourceGroupName to create a new workspace.
  (An unused workspaces may cost about a `$1 per day for storage)

  "
  write-warning "Halted at step 3. Choose or Create a Workspace.
  "
  exit
}
"✅ OK"

# ----------------------------------------------------------------------------
"
4. Choose or Create a computetarget $computeTargetName"

if($computeTargetName ){
  "Looking for existing computetarget called $computeTargetName ..."
  az ml computetarget show --output table `
            --name $computeTargetName -w $workspaceName -g $resourceGroupName
  if(-not $?){
    "... none found.

    4.1 Create a new computetarget $computeTargetName of size $($computeTargetSize)? 
    (This will be created with min-nodes=0 and max-nodes=1 so it will be free when not in use)"

    Ask-YesElseThrow
    az ml computetarget create amlcompute -n $computeTargetName --min-nodes 0 --max-nodes 1 `
        --vm-size Standard_$computeTargetSize -w $workspaceName -g $resourceGroupName

    if(-not $?){
      throw "failed at az ml computetarget create amlcompute 
        -n computeTargetName --min-nodes 0 --max-nodes 1 
        --vm-size Standard_$computeTargetSize -w $workspaceName -g $resourceGroupName"
    }
  }
}else{
  "You current have these computetargets in $workspaceName in $resourceGroupName"
  $r=(az ml computetarget list -w $workspaceName -g $resourceGroupName --output table)
  $r
  if(-not $r){"-- none --"}
  "
  Create a new computetarget by specifying `$computeTargetName and optional 
  `$computeTargetSize.
  • Size will default to 'nc6'
  • It will be created with min-nodes=0 and max-nodes=1, so it will be free when not in use
  "
  write-warning "Halted at step 4. Create a computetarget.
  "
  exit
}
"✅ OK" 

# ----------------------------------------------------------------------------

"
5. Attach the current folder to the workspace $workspaceName in resource group $resourceGroupName

Your current path is $(Get-Location)
Your experimentName is $experimentName"

if(test-path ".azureml/"){
  "
  This directory is already attached:"
  get-childitem .azureml/*
}else{
  if(Ask-YesNo "Attach this directory, with experiment-name $($experimentName)?"){
    az ml folder attach -w $workspaceName -g $resourceGroupName --experiment-name $experimentName
    if(-not $?){throw "failed at az ml folder attach -w $workspaceName -g $resourceGroupName --experiment-name $experimentName"}
  }
}

"✅ OK"
# ----------------------------------------------------------------------------

"
6. Define a dataset $datasetDefinitionFile"

if( ($datasetDefinitionFile) -and (test-path $datasetDefinitionFile)){
  "Registering dataset defined by $datasetDefinitionFile"
  az ml dataset register -f "$datasetDefinitionFile" --skip-validation -w $workspaceName -g $resourceGroupName 
  if(-not $?){throw "failed at az ml dataset register -f $datasetDefinitionFile --skip-validation"}
}else{
  $mldatasetlist=(az ml dataset list -g $resourceGroupName -w $workspaceName ) -join [System.Environment]::NewLine
  $existingDatasets=(ConvertFrom-Json $mldatasetlist -NoEnumerate)
  if($existingDatasets.Length -gt 0){
    $mldatasetlist
  }else{
    "
    You have not provided a dataset json file. Would you like to create and register 
    a small dataset-Example.json file? (It will use the mnist 10k dataset)
    "
    if(Ask-YesNo){
        $newDDF=if($datasetDefinitionFile){$datasetDefinitionFile}else{"dataset-Example.json"}        
        '{
            "datasetType": "File",
            "parameters": {
              "path": [
                "http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz",
                "http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz",
                "http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz",
                "http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz"
              ]
            },
            "registration": {
              "createNewVersion": true,
              "description": "mnist dataset",
              "name": "mnist-dataset",
              "tags": {
                "sample-tag": "mnist"
              }
            },
            "schemaVersion": 1
          }' > $newDDF

      Get-Content $newDDF

      az ml dataset register -f "$newDDF" --skip-validation -w $workspaceName -g $resourceGroupName
      if(-not $?){throw "failed at az ml dataset register -f $($newDDF) --skip-validation  -w $workspaceName -g $resourceGroupName"}
    }else{
      "Skipped Step 6. Define a dataset
      "
    }
  }
}

"✅ OK"
# ----------------------------------------------------------------------------
"
7. Create a runconfig referencing your script, dataset, and computetarget
8. Run the runconfig
Not covered: 
9. Attach an Azure blob container as a Datastore for large datasets
10. Upload files to a Datastore.
11. Scaffold and register Environments
"

#az ml environment scaffold -n myenv -d myenvdirectory

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
