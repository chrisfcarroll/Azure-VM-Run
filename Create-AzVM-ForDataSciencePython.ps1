#! /usr/bin/env pwsh -NoProfile
# ----------------------------------------------------------------------------
# The following line is deliberately left blank for powershell help parsing.

<#
.Synopsis
Create-AzVM-ForDataSciencePython.ps1 helps you start a VM suitable for 
data science. 

.Description

The default choices are:
- the linuxdsvmubuntu image version 20.01.09
- an NC6_Promo VM


Required: You must already have an Azure Subscription with permissions to create 
  resources. If you don't have one, you can get a new one for free in about 
  10 minutes at https://azure.com

----------------------------------------------------------------------------
Resources Created

[Azure Subscription]
  └── ResourceGroup (at a location)
      └── VirtualMachine
          ├── ssh-keys
          ├── git
          └── Python Environment with PyTorch, TensorFlow, Scikit etc

----------------------------------------------------------------------------
The Steps

[Prequisite] Install az cli tool & ml extensions and be able to access your account

1. All resources are 'kept' in a ResourceGroup. A ResourceGroup is just a 
   management convenience, tied to a location, but costing nothing.

2. In the Resource Group, create and start a VM.

3. Choose a Git repository to clone 

4. Choose local files to transfer

5. ssh to the VM

6. shutdown the VM

Usage:

Create-AzVM-ForDataSciencePython.ps1 
    [[-name] <String>] 
    [[-resourceGroupName] <String>] 
    [[-size] <String ValidAzureVMSize>] 
    [[-imageUrn] <String Valid Azure VM Image urn>] 
    [-gitRepository <Uri to a git repo you want to clone onto the VM>] 
    [-copyLocalFolder <Path to a local folder you want to copy to the VM>] 
    [-commandToRun <String Commandline to run on the VM>] 
    [-location <String Valid Azure Location ID e.g. uksouth>] 
    [-pricingTier <String Valid Azure Tier e.g. Standard>] 
    [-help] 
    [<CommonParameters>]

.Example
Create-AzVM-ForDataSciencePython.ps1 
    -name DSVM 
    -resourceGroupName ml1 -location uksouth
    -size nc6_promo
    -image-urn microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09

-creates or confirms a resourceGroup named ml1 in Azure location uksouth
-creates or confirms a VM with the given name, size and image and with ssh-keys

.Example
Create-AzVM-ForDataSciencePython.ps1 
    -name DSVM 
    -resourceGroupName ml1
    -size standard_nc6_promo
    -image-urn microsoft-ads:linux-data-science-vm:linuxdsvm:20.08.06
    -gitRepository https://github.com/chrisfcarroll/TensorFlow-2.x-Tutorials
    -copyLocalFolder tf-wip
    -commandToRun "python TensorFlow-2.x-Tutorials/11-AE/ex11AE.py"

-confirms a resourceGroup named ml1
-creates or confirms a VM with the given name, size and image and with ssh-keys
-clones the given git repo into the path ~/TensorFlow-2.x-Tutorials
-copies local Folder tf-wip into the path ~/tf-wip
-runs the command "python TensorFlow-2.x-Tutorials/11-AE/ex11AE.py" in a detached tmux session

#>
[CmdletBinding(PositionalBinding=$false)]
Param(
  #Required. Name of the VM to create or confirm
  [Parameter(Position=0)][string]$name='DSVM',

  ##Required. A new or existing Azure ResourceGroup name.
  ##https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal
  [Alias('g')][Parameter(Position=1)][string]$resourceGroupName, 

  ##Size of the VM to create
  [Parameter(Position=2)]
  [ValidateSet('NC6','NC12','NC24','NC6V3','NC12V3','NC24V3','NC6_PROMO','NC12_PROMO','NC24_PROMO', 'NV4AS_V4', 'NV4AS_V4', 'NV8AS_V4')]
  [string]$size='NC6_PROMO',

  ##Image urn to use for the VM
  [Parameter(Position=3)][string]$imageUrn="microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09",

  ##Uri of git repository to clone 
  [Uri]$gitRepository,

  ##Path of a folder on your local machine to copy to the VM
  [ValidateScript({Test-Path $_ -PathType 'Container'})][string]$copyLocalFolder,

  ##Command to execute after copyLocalFolder (if any) and after cloning gitRepository (if any)
  ##The command will run in a detached tmux session
  [string]$commandToRun="~/$copyLocalFolder/train.py",

  #Azure location. Only needed to create a new resourceGroup
  [string]$location,

  ##Azure pricing tier.
  [ValidateSet('Free', 'Shared', 'Basic', 'Standard', 'Premium', 'Isolated')][string]$pricingTier="Standard",

  ##show this help text
  [switch]$help
)
# ----------------------------------------------------------------------------
function Ask-YesNo($msg){return ($noConfirm -or ($Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -eq 0))}
function Ask-YesElseThrow($msg){
  if(-not $noConfirm -and $Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -ne 0){throw "Halted because you said No"}
}

# ----------------------------------------------------------------------------
if(-not $name -or -not $resourceGroupName -or $help)
{
  Get-Help $PSCommandPath
  "
  You must specify at least one of -name (if a VM already exists) or -resourceGroupName.
  If you don't yet have a Resource Group, you must also specify -location to create a new Resource Group.
  "
  exit
}

# ----------------------------------------------------------------------------
"
[Prequisite] Is az CLI is installed and the az Machine Learning CLI extension?"
$azcli=(Get-Command az -ErrorAction SilentlyContinue)
if($azcli){
  "✅ Found at " + $azcli.Path
}else{
  Start-Process "https://www.bing.com/search?q=install+az+cli+site:microsoft.com"
  throw "az cli not found in path. 
        Find installation instructions via https://www.bing.com/search?q=install+az+cli+site:microsoft.com
        Having installed the CLI, don't forget to 
        >az login 
        to confirm you can connect to your subscription."
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
1. Choose or Create a ResourceGroup $resourceGroupName
"
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

    Halted at step 1. Choose or Create a ResourceGroup.
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
  write-warning "Halted at step 1. Choose or Create a ResourceGroup.
  "
  exit
}
# ----------------------------------------------------------------------------

"
2. Check for existing VM called $name in $resourceGroupName ...
"
$vmIp=(az vm list-ip-addresses -g $resourceGroupName --name $name --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress")
if($vmIp){"Found at $vmIP"}else{"Creating new VM ..."}
"✅ OK"

#-----------------------------------------------------------------------------

if(-not $vmIp){
  "
  3. Accepting the license for --image $imageUrn ... 
  "
  az vm image terms accept --urn $imageUrn

  if($?){"✅ OK"}  
}

# ----------------------------------------------------------------------------

if(-not $vmIp){
  "
  4. Create VM --name $name 
               --resource-group $resourceGroupName 
               --size $($pricingTier)_$size 
               --image $imageUrn
               --generate-ssh-keys

  "

  if($vmIp){

    write-warning "A VM called $name already exists. Skipping creation."

  }else{

    $result=(az vm create -g ml1 --name $name --image $imageUrn --generate-ssh-keys --size "$($pricingTier)_$size")
    if(-not $?){write-warning $result}

    $vmIp= (ConvertFrom-Json ($result -join " ") -NoEnumerate -AsHashtable).publicIpAddress
  }

  if($?){"✅ OK"}  
}

# --------------------------------------------------------------------------
"
5. Connect to the VM, create working directory, download git repo, copy copyLocalFolder
"

if($copyLocalFolder){
  "
  5.1 Copying $copyLocalFolder/* to VM ...
  "
  ssh $vmIp mkdir -p $copyLocalFolder
  scp $copyLocalFolder/* $($vmIp):$copyLocalFolder
}

if($gitRepository){
  "
  5.2 Git cloning $gitRepository ...
  "
  ssh $vmIp "git clone $gitRepository"
}
"✅ OK"

# --------------------------------------------------------------------------
"
6. Run command $commandToRun in a detached tmux session ...
"
if($commandToRun){
  ssh $vmIp -t tmux new-session -d -s "Create-AzVM-ForDataSciencePython-CommandToRun" $commandToRun
}else{
  "No command specified"
}
"✅ OK"
