#! /usr/bin/env pwsh
# ----------------------------------------------------------------------------
Param(
  [string]$resourceGroupName,
  [string]$workspaceName,
  [string]$location,
  [string]$experimentName=(Split-Path (Get-Location) -Leaf)
  [ValidateSet('nc6','nc12','nc24','nc6v3','nc12v3','nc24v3',),][string]$vmSize='nc6'
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
# ----------------------------------------------------------------------------
if(-not $resourceGroupName -and -not $workspaceName)
{

  "
  What is needed to create, use, and tear down cloud-based ML training resources?

  1. All resources are 'kept' together in a ResourceGroup. A ResourceGroup is just a
  management convenience, tied to a location, but costing nothing.
 
  2. In the resourceGroup, you must create a Workspace. This will allocate some storage, and
  an unused workspace will cost you around `$1 per day. It may take a couple of minutes to
  create, and slightly less time to delete.

  3. Within the workspace, you create compute instances or compute clusters. Clusters Scalesets have
  the advantage of auto-scaling down to 0 nodes–i.e. no cost—when not in use.

  Optionally: 

  -Add storage to your workspace. This storage can be shared across computeinstances 
  in the workspace.

  -Attach a local folder on your desktop to the workspace.

  Usage:

    $PSCommandPath [-resourceGroupName] <name> [-workspaceName] <name> [-location <name>]
  "
}

  $PSScriptRooT

# ----------------------------------------------------------------------------
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
"✅ OK"

# ----------------------------------------------------------------------------
"
5. Create a new computeinstance
"
az ml computetarget create amlcompute -n cpu --min-nodes 1 --max-nodes 1 -s $vmSize

# ----------------------------------------------------------------------------

"
6. Attach an Azure blob container as a Datastore.
"
# ----------------------------------------------------------------------------
"
7. Attach the current folder to the workspace $workspaceName in resource group $resourceGroupName

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
8. Upload files to a Datastore.
9. Scaffold and register an Environment 
10. Start a computeinstance and run an experiment
"

#az ml environment scaffold -n myenv -d myenvdirectory

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
