#! /usr/bin/env pwsh
# ----------------------------------------------------------------------------
Param(
  [string]$resourceGroupName,
  [string]$workspaceName,
  [string]$location,
  [string]$experimentName=(Split-Path (Get-Location) -Leaf)
)
# ----------------------------------------------------------------------------
function Ask-YesNo($msg){return ($Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -eq 0)}
function Ask-YesElseThrow($msg){
  if($Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -ne 0){throw "Halted because you said No"}
}
# ----------------------------------------------------------------------------
"
This script will go through steps in 
https://docs.microsoft.com/en-us/azure/machine-learning/reference-azure-machine-learning-cli
needed to set up and use compute targets for training a model.
"

"
1. Check az CLI is installed"
$azcli=(Get-Command az -ErrorAction SilentlyContinue)
if($azcli){
  "✅ Found at " + $azcli.Path
}else{
  Start-Process "https://www.bing.com/search?q=install+az+cli+site:microsoft.com"
  throw "az cli not found in path. Find installation instructions via https://www.bing.com/search?q=install+az+cli+site:microsoft.com"
}

# ----------------------------------------------------------------------------
"
2. Ensure the az Machine Learning CLI extension is installed"
az extension add -n azure-cli-ml
if($?){"✅ OK"}

# ----------------------------------------------------------------------------
"
3. Choose a ResourceGroup"
if($resourceGroupName ){
  az group show --output table --name $resourceGroupName --query [name,location]
  if($?){
    "✅ OK"    
  }elseif($location){
      "3.1 Create ResourceGroup $resourceGroupName in location $location? (Creating a resource group is free)"
      Ask-YesElseThrow
      az group create --name $resourceGroupName --location $location
      if($?){throw "failed at az group create --name $resourceGroupName --location $location"}
  }else{
    "
    To create ResourceGroup $resourceGroupName you must also specify a `$location.

    Halted at step 3 Choose ResourceGroup.
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

  Halted at step 3. Choose a ResourceGroup.
  "
  exit
}

# ----------------------------------------------------------------------------

"
4. Choose a Workspace"

if($workspaceName){
  az ml workspace show --workspace-name $workspaceName --resource-group $resourceGroupName --query [name,resourceGroup,location]
  if($?){
    "✅ OK"
  }else{
      "4.1 Create Workspace $workspaceName in Group $resourceGroupName?

      (An unused workspaces may cost about a `$1 per day for storage)
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

  Halted at step 4. Choose a Workspace.
  "
  exit
}


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
6. Attach an Azure blob container as a Datastore.
7. Upload files to a Datastore.
8. Scaffold and register an Environment 
8. Create a new computeinstance
9. Start a computeinstance and run an experiment
"

#az ml environment scaffold -n myenv -d myenvdirectory

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
