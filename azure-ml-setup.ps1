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
              └── runconfig (which references Dataset, Computetarget and a script)

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

6. Define a Dataset

7. Choose an Environment by name

8. Create a runconfig referencing your environment, script, dataset, computetarget

9. Run the runconfig

--------------------------------------------------------------------------
Not covered by this script:
10. Attach an Azure blob container as a Datastore for large datasets
11. Upload files to a Datastore
For these steps you may want an example or a tutorial, not a script.
----------------------------------------------------------------------------

Usage:

azure-ml-setup.ps1 
    [[-resourceGroupName] <String>] [[-location] <String>]
    [[-workspaceName] <String>] 
    [[-computeTargetName] <String>] [[-computeTargetSize] <String>] 
    [[-experimentName] <String>] 
    [[-datasetDefinitionFile] <String>] 
    [[-environmentMatch] <String>] [[-environmentName] <String>] 
    [-help] [<CommonParameters>]

#>
Param(
  ##Required for step 2 and further. A new or existing Azure ResourceGroup name.
  ##https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal
  [string]$resourceGroupName, 
  ##Required for step 3 and further. A new or existing workspace, which will hold references to 
  ##your data and computetargets
  [string]$workspaceName,
  ##Used for steps 4, 8, 9. A new or existing Azure computetarget to run on
  [string]$computeTargetName,
  ##Only required when creating a new computetarget at step 4. The pre-selected options are the ones with a GPU
  [ValidateSet('nc6','nc12','nc24','nc6v3','nc12v3','nc24v3','nc6promo','nc12promo','nc24promo')]
    [string]$computeTargetSize='nc6',
  ##Used for steps 5, 8, 9.
  [string]$experimentName= (Split-Path (Get-Location) -Leaf),
  ##Optional
  [ValidateScript({Test-Path $_ -PathType 'Leaf'})][string]$datasetDefinitionFile,
  ##Usable for steps 7,8,9 as a convenience. Using this will pick the alphabetically last matching environment,
  ##which will typically be the one with the highest version number
  [ValidateSet('TensorFlow','PyTorch','Scikit','PySpark','Minimal','AzureML-Tutorial','TensorFlow-2','TensorFlow-1','PyTorch-1.6')]
    [string]$environmentMatch,
  ##Usable for steps 7,8,9 when you know the exact environmentName you require.
  ##See https://docs.microsoft.com/en-us/azure/machine-learning/resource-curated-environments for Azure-curated environments
  [string]$environmentName,
  ##An Azure region name. Only required when creating a new ResourceGroup at step 2. 
  ##Thereafter the ResourceGroup is all the location you need.
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
  "Looking for existing computetarget called $computeTargetName ... (please wait a while) ..."
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
  $chosenDatasetFile=$datasetDefinitionFile
}else{
  $mldatasetlist=(az ml dataset list -g $resourceGroupName -w $workspaceName ) -join [System.Environment]::NewLine
  $existingDatasets=(ConvertFrom-Json $mldatasetlist -NoEnumerate)
  if($existingDatasets.Length -gt 0){
    $mldatasetlist
    $chosenDatasetFile=$null #none chosen but that's fine
  }else{
    "
    You have not provided a dataset json file. Would you like to create and register 
    a small dataset-Example.json file? (It will use the mnist 10k dataset)
    "
    if(Ask-YesNo){
        $chosenDatasetFile=if($datasetDefinitionFile){$datasetDefinitionFile}else{"dataset-Example.json"}        
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
          }' > $chosenDatasetFile

      Get-Content $chosenDatasetFile

      az ml dataset register -f "$chosenDatasetFile" --skip-validation -w $workspaceName -g $resourceGroupName
      if(-not $?){throw "failed at az ml dataset register -f $($chosenDatasetFile) --skip-validation  -w $workspaceName -g $resourceGroupName"}
    }else{
      "Skipped Step 6. Define a dataset
      "
    }
  }
}

"✅ OK"
# ----------------------------------------------------------------------------
"
7. Choose an Environment by name
"
if($environmentName){
    $chosenEnvironmentName=$environmentName
    az ml environment show  --name $environmentName -w $workspaceName --output table
    if(-not $?){
      write-warning "
      You asked for environment $environmentName , but no such was found.
      To choose an Azure curated environment, instead use 
      -environmentFor TensorFlow | PyTorch | Tutorial | ... instead
      which will find a matching curated Azure ML environment.

      This script doesn't cover creating your own custom environment.

      Halted at 7. Choose an Environment, because your choice wasn't found.
      "
      exit
    }
  }elseif($environmentMatch){
    "7.1 Looking for an existing environment matching $environmentMatch ...
    "
    $matchesj=(az ml environment list -w $workspaceName `
                --query "[?contains(name,`'$environmentMatch`')].name") `
                -match '".*"'
    if($matchesj.Length -eq 0){
      write-warning "
      You asked for a curated environment matching $environmentMatch , but no such was found.
      Here are all known environments available to your workspace:
      "
      az ml environments list -w $workspaceName --output table
      write-warning "
      Halted at 7. Choose an Environment, because your choice $environmentMatch wasn't found.
      "
      exit
    }else{
      $matches=( $matchesj | %{ $_.Trim(" ,`"") })
      $chosenEnvironmentName=($matches | Sort-Object -Descending)[0]
      "Found:"
      $matches
      "
      7.1 Choosing $chosenEnvironmentName as the alphabetically last match."
    }
  }else{
    "Choose an environment either with 

    -environmentName <existing-environment-name>

    -environmentFor <string-to-search-in-azure-curated-environments-eg-Tensorflow>
    "

    write-warning "
    Halted at 7. Choose an Environment, because you didn't."
  }


"✅ OK"
# ----------------------------------------------------------------------------
"
8. Create a runconfig referencing your environment, script, dataset, computetarget

Got:
   ResourceGroup  : $resourceGroupName 
   Workspace      : $workspaceName 
   ComputeTarget  : $computeTargetName 
   Environment    : $chosenEnvironmentName
   New Dataset?   : $(if($chosenDatasetFile){$chosenDatasetFile}else{'(no new dataset defined)'})
   Experiment Name: $experimentName
   Local directory attached? : $(if(test-path ".azureml/"){'Yes'}else{'No'})
   "


"✅ OK"
# ----------------------------------------------------------------------------
"
9. Run the runconfig

Not covered: 
10. Attach an Azure blob container as a Datastore for large datasets
11. Upload files to a Datastore
"

#az ml environment scaffold -n myenv -d myenvdirectory

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
