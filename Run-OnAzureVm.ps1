#! /usr/bin/env pwsh -NoProfile
# ----------------------------------------------------------------------------
# The following line is deliberately left blank for powershell help parsing.

<#
.Synopsis

Run-OnAzureVM.ps1 helps you to:
  -create a VM preloaded for data science training with a GPU
  -copy files & clone a git repo onto the VM
  -set a commmand running
  -check for and retrieve outputs

More detail : https://github.com/chrisfcarroll/Azure-az-ml-cli-QuickStart

.Description

This Script will Take You Through These Steps
---------------------------------------------

[Step zero] Install az cli tool & ml extensions. Be able to access your account

1. Create a Resource Group. This is Azure's way to 'keep together' related
   resources. It is tied to an azure location and is free.

2. In the Resource Group, create and start a VM.

3. Choose a Git repository to clone on the VM

4. Choose local files to transfer to the VM

6. Run a command on the VM, in a tmux session, after first updating any specified python packages

7. ssh to the VM for an interactive session

8. Copy output from the VM back to your local working directory

----------------------------------------------------------------------------
Resources Created

[Azure Subscription]
  └── ResourceGroup (at a location)
      └── VirtualMachine (with a size and an image)
          ├── ssh-keys
          ├── git
          └── Python Environment with PyTorch, TensorFlow, Scikit etc

The VM defaults to:
- image = linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09
- size  = NC6_Promo

Teardown:

Delete resources with one of:
```
az vm delete --name ml1
az group delete --name ml1
```

----------------------------------------------------------------------------

Usage:

Run-OnAzureVM.ps1 
    [[-name] <String>] 
    [-resourceGroupName] <String> [-location <String Valid Azure Location ID e.g. uksouth>] 
    [[-size] <String ValidAzureVMSize>]
    [[-imageUrn] <String Valid Azure VM Image urn>] 
    [-packagesToUpgrade <Array of package names to update>] 
    [-gitRepository <Uri to a git repo you want to clone onto the VM>] 
    [-copyLocalFolder <Path to a local folder you want to copy to the VM>] 
    [-commandToRun <String Commandline to run on the VM>]
    [-noConfirm] 
    [-help] 
    [-fetchOutputs  [-fetchOutputFrom <Path default=outputs>]]
    [<CommonParameters>]

.Example
Run-OnAzureVM.ps1 
    -name DSVM 
    -resourceGroupName ml1 -location uksouth
    -size nc6_promo
    -image-urn microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09

-creates or confirms a resourceGroup named ml1 in Azure location uksouth
-creates or confirms a VM with the given name, size and image and with ssh-keys

.Example
Run-OnAzureVM.ps1 
    -name DSVM 
    -resourceGroupName ml1
    -size standard_nc6_promo
    -image-urn microsoft-ads:linux-data-science-vm:linuxdsvm:20.08.06
    -gitRepository https://github.com/chrisfcarroll/TensorFlow-2.x-Tutorials
    -copyLocalFolder my-project
    -commandToRun "python TensorFlow-2.x-Tutorials/11-AE/ex11AE.py"

-confirms a resourceGroup named ml1
-creates or confirms a VM with the given name, size and image and with ssh-keys
-clones the given git repo into the path ~/TensorFlow-2.x-Tutorials
-copies local Folder tf-wip into the path ~/my-project
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
  [ValidateSet('NC6','NC12','NC24','NC6V3','NC12V3','NC24V3','NC6_PROMO','NC12_PROMO','NC24_PROMO', 'NV4AS_V4', 'NV4AS_V4', 'NV8AS_V4', 'B1s')]
  [string]$size='NC6_PROMO',

  ##Image urn to use for the VM
  [string]$imageUrn="microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09",

  ##The packages that will be specified to create the default (that is, set in .bashrc)
  ##conda environment on the VM 
  [string]$condaEnvironmentSpec="tensorflow=2.2 pytorch=1.5 scikit-learn matplotlib pillow",

  ##Packages to pip upgrade after setting up -condaEnvironmentSpec
  ##Not usually required as you can use -condaEnvironmentSpec instead
  [string[]]$pipPackagesToUpgrade,

  ##Uri of a git repository to clone. The git clone command will be execute from the home 
  ##directory
  [Uri]$gitRepository,

  ##Path of a folder on your local machine to copy to the VM
  ##If $copyLocalFolder is not simply a subdirectory of the current working folder then
  ##it will be copied to a folder under the home directory with the same name as the
  ##last part of the folder's path. 
  ## eg:
  ## -copyLocalFolder "/this/path/is/notasubdirectory" will be copied to "~/notasubdirectory/"
  ## -copyLocalFolder "/this/path/is/asubdirectory"    will be copied to "~/asubdirectory/"
  ## -copyLocalFolder "." will result in all contents of the current working directory
  ##being copied straight into the home directory
  [ValidateScript({Test-Path $_ -PathType 'Container'})][string]$copyLocalFolder="dependencies",

  ##Command to execute after copyLocalFolder (if any) and after cloning gitRepository (if any)
  ##The command will run in a detached tmux session
  ##The command will be passed to bash, so if it is a python script then use e.g. "python script.py"
  [string]$commandToRun="python --version",

  ##Use this switch to check for and retrieve results from an existing VM which
  ##is or has already run a command generating output.
  ##The contents of directory $fetchOutputsFrom (default: outputs) will be copied
  ##to a local directory of the same name (relative to the current working directory)
  [switch]$fetchOutputs,

  ##When using $fetchOutputs, where to look for outputs. You will want to make sure that
  ##your script outputs to this directory
  ##If $fetchOutputsFrom is not simply a subdirectory of the VM's home directory
  ##it will be copied to a folder under your curernt working directory with the same name as the
  ##last part of the folder's path. 
  ## eg:
  ## -fetchOutputsFrom "/this/path/is/notasubdirectory" will be copied to "./notasubdirectory/"
  ## -fetchOutputsFrom "/this/path/is/asubdirectory"    will be copied to "./asubdirectory/"
  ## -fetchOutputsFrom "" will result in _all_ contents of the home directory
  ##being copied straight into the current working directory.
  [string]$fetchOutputsFrom="outputs",

  #Azure location. Only needed if you are creating a new Resource Group
  [string]$location,

  ##Whether to answer yes to all questions and continue without user confirmation
  [Alias('YesToAll')][switch]$noConfirm,

  ##show this help text
  [switch]$help
)
# ----------------------------------------------------------------------------
function Ask-YesNo($msg){return ($noConfirm -or ($Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -eq 0))}
function Ask-YesElseThrow($msg){
  if(-not $noConfirm -and $Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -ne 0){throw "Halted because you said No"}
}

# ----------------------------------------------------------------------------
if(-not $name -or (-not $resourceGroupName -and -not $fetchOutputs) -or $help)
{
  if(get-command less){Get-Help $PSCommandPath -Full | less}
  elseif(get-command more){Get-Help $PSCommandPath -Full | more}
  else{Get-Help $PSCommandPath -Full}  
  exit
}

# ----------------------------------------------------------------------------
"
[Prequisite] Is az CLI is installed and the az Machine Learning CLI extension?"
$azcli=(Get-Command az -ErrorAction SilentlyContinue)
if($azcli){
  "✅ Found cli at " + $azcli.Path
}else{
  Start-Process "https://www.bing.com/search?q=install+az+cli+site:microsoft.com"
  throw "az cli not found in path. 
        Find installation instructions via https://www.bing.com/search?q=install+az+cli+site:microsoft.com
        Having installed the CLI, don't forget to 
        >az login 
        to confirm you can connect to your subscription."
}
" Ensure the ml extension is installed?"
az extension add -n azure-cli-ml
if($?){
  "✅ az ml extension installed"
}else{
  Start-Process "https://www.bing.com/search?q=az+cli+install+extension+ml+failed"
  throw "Failed when adding extension azure-cli-ml. Not sure where to go from here."
}

"Ensure you are logged in"
$r= (az account show --query "{name:name,state:state}")
if($?){
  $doesAccountLookFree= (ConvertFrom-Json ($r -join "")).name -match '^Free|Trial'
  if($doesAccountLookFree){
    write-warning "
    --------------------------------------------------------------------
    It looks like your account is Free Tier?
    Standard_B1s will be the only VM size available to you.
    
    Note that e.g. the TensorFlow build on the linux-data-science-vm
    expects a GPU which you won't have. To use the DSVM on Free Trial
    you will have to manually install non-GPU builds

    Setting size to B1s.
    --------------------------------------------------------------------
    "
    $size='B1s'
  }
  "✅ OK"
}else{
  write-warning "You must login first with az login."
  exit
}

# ----------------------------------------------------------------------------
"
1. Choose or Create a ResourceGroup $resourceGroupName
"
if($resourceGroupName ){
  "Looking for existing resource group called $resourceGroupName ..."
  az group show --output table --name $resourceGroupName
  if($?){
    "✅ Resource Group $resourceGroupName already exists"
  }elseif($location){
      "... none found.

      2.1 Create a new ResourceGroup $resourceGroupName in location $($location)? 
      (Creating a resource group is free and usually takes less than a minute)"
      Ask-YesElseThrow
      az group create --name $resourceGroupName --location $location
      if($?){
        "✅ Resource Group $resourceGroupName created"
      }else{
        throw "failed at az group create --name $resourceGroupName --location $location"
      }
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
2. Check for existing VM called $name in $resourceGroupName
"
$vmIp=(az vm list-ip-addresses -g $resourceGroupName --name $name `
       --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress|[0]" `
       )
if($vmIp){
  $vmIp=$vmIp.Trim('"')
  "Found at $vmIP" ; 
  }else{
    "✅ No such VM exists. Creating a new VM ..."
  }
"✅ OK"

#-----------------------------------------------------------------------------

if(-not $vmIp){
  "
  3. Accepting the license for --image $imageUrn ... 
  "
  az vm image terms accept --urn $imageUrn

  if($?){"✅ OK"}  

}
elseif($vmIp -and $fetchOutputs)
{
  "
  Polling for output in $fetchOutputsFrom ...
  "
  $target=$(if(-not $fetchOutputFrom -or ($fetchOutputFrom -eq ".")){"."}else{Split-Path $fetchOutputsFrom -Leaf})
  scp -r $vmIp`:$fetchOutputsFrom $target
  if(-not $target -or (Test-Path $target)){"Done."}else{"... but nothing copied."}
  exit
}

# ----------------------------------------------------------------------------

if(-not $vmIp){
  "
  4. Create VM --name $name 
               --resource-group $resourceGroupName 
               --admin-username azureuser 
               --size Standard_$size 
               --image $imageUrn
               --generate-ssh-keys

  "

  if($vmIp){

    write-warning "A VM called $name already exists. Skipping creation."

  }else{

    $isNewlyCreatedVM=$true
    $result=(az vm create -g $resourceGroupName --admin-username azureuser --name $name --image $imageUrn --generate-ssh-keys --size Standard_$size)
    $ok=$?
    if(-not $ok){
      write-warning "$ok $result"
      write-warning "
      Stopping because the command

      >az vm create -g $resourceGroupName --name $name --admin-username azureuser --image $imageUrn --generate-ssh-keys --size Standard_$size

      failed.
      "
      exit
    }

    $vmIp= (ConvertFrom-Json ($result -join " ") -NoEnumerate -AsHashtable).publicIpAddress
  }

  if($?){"✅ OK"}  
}

# --------------------------------------------------------------------------
"
5. Connect to the VM, create working directory, download git repo, copy local folder
"

if($isNewlyCreatedVM){
  "
  You may have to wait a minute or more before the VM is ready to accept connections ...
  "
  do{
    'Waiting for VM to accept connections ...'
    sleep 10
    ssh azureuser@$vmIp uname -a
    $didConnect= $?
  }until($didConnect)

  "
  Setting .bashrc to load and run anaconda in non-interactive shells
  "
  ssh azureuser@$vmIp /data/anaconda/bin/conda init bash
  ssh azureuser@$vmIp sed -i "'s/\*) return;;/*) ;;#dont return/'" .bashrc
  "
  Creating conda environment for $condaEnvironmentSpec $pipPackagesToUpgrade
  "
  ssh azureuser@$vmIp "conda create -n ml $condaEnvironmentSpec --yes"
  ssh azureuser@$vmIp 'echo "conda activate ml" >> .bashrc'
  ssh azureuser@$vmIp "python --version && pip install $pipPackagesToUpgrade --upgrade"
}
$sshOK=@()


if($copyLocalFolder){
  if( ($copyLocalFolder -eq ".") -or ($copyLocalFolder -eq $(pwd))){
    $source="./*"
  }else{
    $source=$copyLocalFolder
  }
  "
  5.1 Copying $source to VM
  "
  scp -r $source azureuser@$vmIp`:
  $sshOK += ,$(if($?){"✅ copyLocalFolder"}else{"❌ copyLocalFolder errored"})
}

if($gitRepository){
  "
  5.2 Git cloning $gitRepository ...
  "
  ssh azureuser@$vmIp "git clone $gitRepository"
  $sshOK += ,$(if($?){"✅ git cloned"}else{"❌ git clone errored"})
}
"✅ OK"

# --------------------------------------------------------------------------
if($commandToRun){
"
6. Run command $commandToRun in a tmux session named main ...

   Use tmux to create/detach from long running jobs.
   To detach from the tmux session use the key sequence Ctrl-B d
   To reattach to it, use:
   > ssh azureuser@$vmIp -t tmux attach -t main
"

  $tmuxbashcommand= "bash -ilc `'$($commandToRun -replace '"','\"' -replace "'","\'")`'"
  #bash is better: can run multiple commands. $tmuxcommand= $($commandToRun -replace '"','\"' -replace "'","\'")
  ssh azureuser@$vmIp -t tmux new-session -s main $tmuxbashcommand
  $sshOK += ,$(if($?){"✅ Ran command."}else{"❌ start command errored"})
}
$sshOK

"
VM is ready for you to connect with ssh:

> ssh azureuser@$vmIp
"
