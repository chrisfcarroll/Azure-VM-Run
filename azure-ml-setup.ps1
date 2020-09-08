#! /usr/bin/env pwsh
# ----------------------------------------------------------------------------
Param(
  [string]$resourceGroupName,
  [string]$workspaceName,
  [string]$computeTargetName,
  [ValidateSet('nc6','nc12','nc24','nc6v3','nc12v3','nc24v3','nc6promo','nc12promo','nc24promo')]
    [string]$computeTargetSize='nc6',
  [string]$experimentName= (Split-Path (Get-Location) -Leaf),
  [ValidateScript({Test-Path $_ -PathType 'Leaf'})][string]$datasetDefinitionFile,
  [string]$location
)
# ----------------------------------------------------------------------------
function Ask-YesNo($msg){return ($Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -eq 0)}
function Ask-YesElseThrow($msg){
  if($Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -ne 0){throw "Halted because you said No"}
}
# ----------------------------------------------------------------------------
# don't use https://docs.microsoft.com/en-us/azure/machine-learning/tutorial-train-deploy-model-cli
"
This script will go through steps in 
https://docs.microsoft.com/en-us/azure/machine-learning/tutorial-train-deploy-model-cli
needed to set up and use compute targets for training a model.

Show me the GUI?

The GUI way to do this is at https://ml.azure.com, which will take you through
similar steps as this script.

"
# ----------------------------------------------------------------------------
$commandName=(Split-Path $PSCommandPath -Leaf)
if(-not $resourceGroupName -and -not $workspaceName)
{

  "
  ----------------------------------------------------------------------------
  Usage:

  $commandName [-resourceGroupName] <name> [-workspaceName] <name>
             [[-location] <name>]

  ----------------------------------------------------------------------------

  What is needed to create, use, & tear down cloud-based ML resources?

  1. Install az cli tool & ml extensions

  2. All resources are 'kept' together in a ResourceGroup. A ResourceGroup is 
  just a management convenience, tied to a location, but costing nothing.
 
  3. In the resourceGroup, you must create a Workspace. This will allocate
  some storage, and an unused workspace will cost you around `$1 per day. It
  may take a couple of minutes to create, and slightly less time to delete.

  4. Within the workspace, you create compute instances or compute clusters. 
  Clusters have the advantage they can auto-scale down to 0 nodes–i.e. no cost—
  when idle.

  Optionally: 

  5. Attach a local folder on your desktop to the workspace.

  6. Define a dataset

  7. Attach an Azure blob container as a Datastore for large datasets
  8. Upload files to a Datastore
  9. Scaffold and register Environments
  10. Start a computetarget and run an experiment

  For these final steps you want an example or a tutorial, not a script.

  ----------------------------------------------------------------------------
  "
}

# ----------------------------------------------------------------------------
"
1. Check az CLI is installed and ensure the az Machine Learning CLI extension is installed"
$azcli=(Get-Command az -ErrorAction SilentlyContinue)
if($azcli){
  "✅ Found at " + $azcli.Path
}else{
  Start-Process "https://www.bing.com/search?q=install+az+cli+site:microsoft.com"
  throw "az cli not found in path. Find installation instructions via https://www.bing.com/search?q=install+az+cli+site:microsoft.com"
}
az extension add -n azure-cli-ml
if($?){
  "✅ OK"
}else{
  Start-Process "https://www.bing.com/search?q=az+cli+install+extension+ml+failed"
  throw "adding extension azure-cli-ml. Not sure where to go from here."
}

# ----------------------------------------------------------------------------
"
2. Choose or Create a ResourceGroup $resourceGroupName"
if($resourceGroupName ){
  az group show --output table --name $resourceGroupName
  if($?){
    "✅ OK"    
  }elseif($location){
      "3.1 Create ResourceGroup $resourceGroupName in location $($location)? 
      (Creating a resource group is free and usually takes less than a minute)"
      Ask-YesElseThrow
      az group create --name $resourceGroupName --location $location
      if($?){throw "failed at az group create --name $resourceGroupName --location $location"}
  }else{
    "
    To create ResourceGroup $resourceGroupName you must also specify a `$location.

    "
    write-warning "Halted at step 3. Choose or Create a ResourceGroup.
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
  write-warning "Halted at step 3. Choose or Create a ResourceGroup.
  "
  exit
}

# ----------------------------------------------------------------------------

"
3. Choose or Create a Workspace $workspaceName"

if($workspaceName){
  az ml workspace show --workspace-name $workspaceName --resource-group $resourceGroupName `
        --output table --query "{name:name,resourceGroup:resourceGroup,location:location}"
  if(-not $?){
    "4.1 Create Workspace $workspaceName in Group $resourceGroupName?
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
  write-warning "Halted at step 4. Choose or Create a Workspace.
  "
  exit
}
"✅ OK"

# ----------------------------------------------------------------------------
"
4. Choose or Create a computetarget $computeTargetName"

if($computeTargetName ){
  az ml computetarget show --output table `
            --name $computeTargetName -w $workspaceName -g $resourceGroupName
  if(-not $?){
    "4.1 Create computetarget $computeTargetName of size $($computeTargetSize)? 
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
  Ask-YesElseThrow "Attach this directory, with experiment-name $($experimentName)?"
  az ml folder attach -w $workspaceName -g $resourceGroupName --experiment-name $experimentName
  if(-not $?){throw "failed at az ml folder attach -w $workspaceName -g $resourceGroupName --experiment-name $experimentName"}
}

"✅ OK"
# ----------------------------------------------------------------------------

"
6. Define a dataset $datasetDefinitionFile"

if( ($datasetDefinitionFile) -and (test-path $datasetDefinitionFile)){
  "Registering dataset defined by $datasetDefinitionFile"
  az ml dataset register -f "$datasetDefinitionFile" --skip-validation -w $workspaceName -g $resourceGroupName 
  if(-not $?){throw "failed at az ml dataset register -f $datasetDefinitionFile --skip-validation"}
}
else{
  "
  You have not provided a dataset json file. Would you like to create and register 
  a small example dataset.json file? (It will use the mnist 10k dataset)
  "
  if(Ask-YesNo){
      if(-not $datasetDefinitionFile){$datasetDefinitionFile="dataset-Example.json"}
      
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
        }' > $datasetDefinitionFile

    Get-Content $datasetDefinitionFile

    az ml dataset register -f "$datasetDefinitionFile" --skip-validation -w $workspaceName -g $resourceGroupName
    if(-not $?){throw "failed at az ml dataset register -f $($datasetDefinitionFile) --skip-validation  -w $workspaceName -g $resourceGroupName"}

  }else{
    "Skipped Step 6. Define a dataset
    "
  }
}

"✅ OK"
# ----------------------------------------------------------------------------
"
7. Attach an Azure blob container as a Datastore for large datasets
8. Upload files to a Datastore.
9. Scaffold and register Environments
10. Start a computetarget and run an experiment
"

#az ml environment scaffold -n myenv -d myenvdirectory

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
