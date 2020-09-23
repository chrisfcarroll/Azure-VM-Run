#! /usr/bin/env pwsh -NoProfile
# ----------------------------------------------------------------------------
# The following line is deliberately left blank for powershell help parsing.

<#
.Synopsis
Start-OnVM.ps1 runs a local command on an Azure VM. 

By default it will:
  -first find or create a Virtual Machine and a Azure resource group to hold it.
  -use the cheapest Azure hardware with a GPU, namely NC6_PROMO 
  -use an Ubuntu DSVM image published by Microsoft, preloaded for data science and ML training
  -accept the license for the VM

Depending on parameters passed it will then:
  -copy files to the VM
  -clone a git repo on the VM
  -set a commmand running
  -copy directories from the VM back to your machine

Start-OnVM.ps1  [[-commandToRun] <String command and args> ]
                [[-copyFromLocal] <Local path> [-recursiveCopy] | -noCopy ] 
                [[-fetchOutput] <Path> [-recursiveFetch ]]
                [-recursiveBothCopyAndFetch]
                [[-gitRepository] <Uri to a git repo to clone onto the VM>]  
                [-condaEnvironmentSpec <String>] [-pipPackagesToUpgrade <String[]>] 
                [-resourceGroupName <String> [-location <Azure Location ID e.g. uksouth>]]
                [-imageUrn <String>] 
                [-vmName <String>] [-vmSize <String>] 
                [-licensedAlreadyAccepted]
                [-noConfirm] 
                [-help]
                [<CommonParameters>]

More detail : https://github.com/chrisfcarroll/Azure-az-ml-cli-QuickStart

.Description

This Script will Take You Through These Steps
---------------------------------------------

[Step zero] Install az cli tool is installed. Be able to access your account.

1. Create a Resource Group. This is Azure's way to 'keep together' related
   resources. It is tied to an azure location and is free.

2. In the Resource Group, create and start a VM.

3. Choose a Git repository to clone on the VM

4. Choose local files to transfer to the VM

6. Run a command on the VM, in a tmux session, after first updating any specified python packages

7. Copy output from the VM back to your local working directory

You can also ssh to the VM for an interactive session.

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
az vm delete --name <name>
az group delete --name <name>
```

Check resources with:
```
az vm list --output table
```

----------------------------------------------------------------------------

.Example
Start-OnVM.ps1 "python main.py" -copy . fetch . -g VM -location uksouth
-First creates or confirms the Azure resources required:
  -creates or confirms a resourceGroup named VM in Azure location uksouth
  -creates or confirms a VM named VM
    - with default size : NC6_PROMO
    - with default image : microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09
    -accepts the license for the image
    -creates a conda/python environment with default spec: 
      python 3.7.x tensorflow=2.2 pytorch=1.5 scikit-learn matplotlib pillow
-Then
  -copies your current working directory (without subdirectories) to the VM
  -runs the given command "python main.py" on the VM in a tmux session
  -copies the VM's home folder back to your local current working directory

.Example
Start-OnVM.ps1 
    "python TensorFlow-2.x-Tutorials/11-AE/ex11AE.py"
    -gitRepository https://github.com/chrisfcarroll/TensorFlow-2.x-Tutorials
    -fetchOutput TensorFlow-2.x-Tutorials/11-AE/images
    -resourceGroupName VM 

-First creates or confirms the Azure resources required:
  -confirms a resourceGroup named VM
  -creates or confirms a VM named VM
    -with default size : NC6_PROMO
    -with default image : microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09
    -accepts the license for the image
    -creates a conda/python environment with default spec: 
      python 3.7.x tensorflow=2.2 pytorch=1.5 scikit-learn matplotlib pillow
-Then
  -clones the given git repo into the path ~/TensorFlow-2.x-Tutorials
-Then runs the given command:
  "python TensorFlow-2.x-Tutorials/11-AE/ex11AE.py" in a detached tmux session
-Then copies the remote directory ~/TensorFlow-2.x-Tutorials/11-AE/images to local path ./images/

.Example
Start-OnVM.ps1 
    -vmName MyOtherVMName 
    -resourceGroupName MyRGName -location uksouth
    -vmSize NC24_PROMO
    -image-urn microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09
    -condaEnvironmentSpec "python 3.8 pytorch=1.5 matplotlib pillow"

Creates or confirms the Azure resources required:
  -creates or confirms a resourceGroup named MyRGName in Azure location uksouth
  -creates or confirms a VM name MyOtherVMName of the given size and image
  - accepts the license for the image
  - creates a conda/python environment with the initial spec given
And finishes.
This can be used to 'warm-start' a VM. My experience has typically been that 
it takes a few minutes to start the first VM of the day

.Example
Start-OnVM.ps1 -fetchOutput some/outputs/ -recursive

-attempts to find and connect to a running VM with the default name, DSVM, 
-recursively copies the remote directory ~/some/outputs/ to a local directory ./outputs/

#>
[CmdletBinding(PositionalBinding=$false)]
Param(
  ##Command to execute after copyFromLocal (if any) and after cloning gitRepository (if any)
  ##The command will run in a detached tmux session
  ##The command will be passed to bash, so if it is a python script then use e.g. "python script.py"
  [Parameter(Position=0)][string]$commandToRun,

  ##Path of a folder or files on your local machine to copy to the VM.
  ##Defaults to ".", which will result in all contents of the current working directory
  ##being copied, with no subdirectories, into the VM's home directory . 
  ##Use the -noCopy switch to override this.
  ##
  ##If $copyFromLocal is not simply a subdirectory of the current working folder then
  ##it will be copied to a folder under the home directory with the same name as the
  ##last part of the folder's path. 
  ## eg:
  ## -copyFromLocal "/this/path/is/notasubdirectory" will be copied to "~/notasubdirectory/"
  ## -copyFromLocal "./asubdirectory"                will be copied to "~/asubdirectory/"
  ##
  [Parameter(Position=1)][ValidateScript({Test-Path $_ })][string]$copyFromLocal,

  ##If true, overrides $copyFromLocal so that nothing is copied.
  [switch]$noCopy,

  ##If true, -copyFromLocal also copies subdirectories
  [switch]$recursiveCopy,

  ##Use this after starting a command on a VM to check for and retrieve results.
  ##You will want to make sure that your script outputs to this directory
  ##If -fetchOutput is not an immediate child subdirectory of the VM's home directory,
  ##then it will be copied to a folder under your current working directory with the same 
  ##name as the last part of the folder's path.
  ## eg:
  ## -fetchOutput "/this/path/is/notasubdirectory" will be copied to "./notasubdirectory/"
  ## -fetchOutput "./a/sub/sub/subdirectory"       will be copied to "./subdirectory/"
  ## -fetchOutput "." or -fetchOutput "~" will copy the VM's home directory
  ##being copied into the current working directory.
  ##
  ##If you are running on bash and want to use wildcards, e.g. "subdirectory/*", don't forget 
  ##to use quotes
  [Parameter(Position=2)][string]$fetchOutput,

  ##If true, -fetchOutput also fetches subdirectories
  [switch]$recursiveFetch,

  ##If true, -copyFromLocal and -fetchOutput also copies subdirectories
  [switch]$recursiveBothCopyAndFetch,

  ##Uri of a git repository to clone. The git clone command will be execute from the home 
  ##directory
  [Parameter(Position=3)][Uri]$gitRepository,


  ##The packages that will be uncluded in the default (that is, set in .bashrc)
  ##conda environment on the VM. Default to common machine learning packages
  [string]$condaEnvironmentSpec="tensorflow-gpu=2.2 pytorch=1.5 scikit-learn matplotlib pillow",

  ##Packages to pip upgrade after setting up -condaEnvironmentSpec
  ##Use this only if you cannot get your required setup with -condaEnvironmentSpec
  [string[]]$pipPackagesToUpgrade,

  ##Required. A new or existing Azure ResourceGroup name.
  ##https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal
  [Alias('g')][string]$resourceGroupName, 

  #Azure location. Only needed if you are creating a new Resource Group
  [string]$location,

  ##Image urn to use for the VM
  [string]$imageUrn="microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09",


  #Required. Name of the VM to create or confirm
  [string]$vmName='DSVM',

  ##Size of the VM to create
  [ValidateSet('NC6','NC12','NC24','NC6V3','NC12V3','NC24V3','NC6_PROMO','NC12_PROMO','NC24_PROMO', 'NV4AS_V4', 'NV4AS_V4', 'NV8AS_V4', 'B1s')]
  [string]$vmSize='NC6_PROMO',

  ##Use this switch to avoid waiting to accept an image license you have already accepted
  [switch]$licensedAlreadyAccepted,

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

if($help)
{
  if(get-command less){Get-Help $PSCommandPath -Full | less}
  elseif(get-command more){Get-Help $PSCommandPath -Full | more}
  else{Get-Help $PSCommandPath -Full}  
  exit
}

$summaryHelp= -not $noConfirm -and -not ($resourceGroupName,$fetchOutput,$copyFromLocal,$commandToRun -gt " " )

if($summaryHelp){

  "
  Start-OnVM.ps1  [[-commandToRun] <String command and args> ]
                  [[-copyFromLocal] <Local path> [-recursiveCopy] | -noCopy ] 
                  [[-fetchOutput] <Path> [-recursiveFetch ]]
                  [-recursiveBothCopyAndFetch]
                  [[-gitRepository] <Uri to a git repo you want to clone onto the VM>]  
                  [-condaEnvironmentSpec <String>] [-pipPackagesToUpgrade <String[]>] 
                  [-resourceGroupName <String> [-location <Azure Location ID e.g. uksouth>]]
                  [-imageUrn <String>] 
                  [-vmName <String>] [-vmSize <String>] 
                  [-licensedAlreadyAccepted]
                  [-noConfirm] 
                  [-help]
                  [<CommonParameters>]

  Start-OnVM.ps1 with no parameters will start a VM if you have a default location set.

  To skip this confirmation, use Start-OnVM.ps1 -noConfirm

  For more help, use Start-OnVM.ps1 -help
  "
  if(-not (Ask-YesNo "Continue?")){
    exit
  }
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

"Ensure you are logged in?"
$r= (az account show --query "{name:name,state:state}")
if($?){
  $doesAccountLookFree= (ConvertFrom-Json ($r -join "")).name -match '^Free|Trial'
  if($doesAccountLookFree){
    write-warning "
    --------------------------------------------------------------------
    It looks like your account is Free Tier?
    Standard_B1s will be the only VM size available to you.
    
    Note that some package on the linux-data-science-vm
    expect a GPU which you won't have. To use the DSVM on Free Trial
    you may have to specify non-GPU built packages

    Setting size to B1s.
    --------------------------------------------------------------------
    "
    $vmSize='B1s'
  }
  "✅ OK"
}else{
  write-warning "You must login first with az login."
  exit
}

# ----------------------------------------------------------------------------
# Get defaults if any, if wanted
#
if(-not $resourceGroupName){
  $resourceGroupName= (az configure -l --query "[?name=='group'].value|[0]")
  if($resourceGroupName){$resourceGroupName=$resourceGroupName.Trim('"')}
}
if(-not $location){
  $location=(az configure -l --query "[?name=='location'].value|[0]")
  if($location){$location= $location.Trim('"')}
}

$recursiveCopy= $recursiveCopy -or $recursiveBothCopyAndFetch
$recursiveFetch= $recursiveFetch -or $recursiveBothCopyAndFetch


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

    If you are not familiar with Azure, try 
    https://www.bing.com/search?q=choose+an+azure+location+near+me+site:microsoft.com
    for a suitable location name.

    You can set defaults for both resource group and location:

    az configure --defaults location=uksouth group=VM
    "
    exit
  }
}else{
  "
  You current have these Resource Groups
  "
  az group list --output table
  "
  Use an existing group by specifying -resourceGroupName , or else specify 
  both -resourceGroupName and -location to create a new ResourceGroup.
  ResourceGroups are free.
  An abbrevation for -resourceGroupName is -g

  "
  write-warning "Halted at step 1. You must choose or create a ResourceGroup.
  You can't create a VM with specifying a resource group for it to belong too.
  If this is your first experience with Azure, you might simply call it ‘VM’
  "
  exit
}
# ----------------------------------------------------------------------------

"
2. Check for existing VM called $vmName in $resourceGroupName
"
$vmIp=(az vm list-ip-addresses -g $resourceGroupName --name $vmName `
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

if($vmIp){

  "A VM called $vmName already exists."

}elseif($licensedAlreadyAccepted){
  "Skipping accept image license because you said the license is already accepted."
}else{
  "
  3. Accepting the license for --image $imageUrn ... 
  "
  az vm image terms accept --urn $imageUrn

  if($?){"✅ OK"}  

}

# ----------------------------------------------------------------------------

if(-not $vmIp){
  "
  4. Create VM --name $vmName 
               --resource-group $resourceGroupName 
               --admin-username azureuser 
               --size Standard_$vmSize 
               --image $imageUrn
               --generate-ssh-keys

  "

  $isNewlyCreatedVM=$true
  $result=(az vm create -g $resourceGroupName --admin-username azureuser --name $vmName --image $imageUrn --generate-ssh-keys --size Standard_$vmSize)
  $ok=$?
  if(-not $ok){
    write-warning "$ok $result"
    write-warning "
    Stopping because the command

    >az vm create -g $resourceGroupName --name $vmName --admin-username azureuser --image $imageUrn --generate-ssh-keys --size Standard_$vmSize

    failed.
    "
    exit
  }

  $vmIp= (ConvertFrom-Json ($result -join " ") -NoEnumerate -AsHashtable).publicIpAddress

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
  ssh azureuser@$vmIp "conda create -n vm $condaEnvironmentSpec --yes"
  ssh azureuser@$vmIp 'echo "conda activate vm" >> .bashrc'
  if($pipPackagesToUpgrade){
    ssh azureuser@$vmIp "python --version && python -m pip install $pipPackagesToUpgrade --upgrade"
  }
}
$sshOK=@()


if(-not $noCopy -and $copyFromLocal){
  if($copyFromLocal -eq "."){
    $source="*"
  }else{
    $source=$copyFromLocal
  }
  "
  5.1 Copying $source to VM $(if($recursiveCopy){"recursively"})
  
  scp  $(if($recursiveCopy){"-r"}) $source azureuser@$vmIp`: ..."  
  if($recursiveCopy){
    scp -r $source azureuser@$vmIp`:
    $sshOK += ,$(if($?){"✅ copyFromLocal"}else{"❌ copyFromLocal errored"})
  }else{
    scp $source azureuser@$vmIp`:
    $sshOK += ,"✅ copyFromLocal" 
    # exit code will be > 0 for non-recursive copy just because of subdirectories
  }
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
  if($commandToRun -match "^\w+\.py( |$)"){
    write-warning "Did you mean `"python $commandToRun`" ?"
  }

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


# --------------------------------------------------------------------------
if($vmIp -and $fetchOutput)
{
  "
  Polling for output in $fetchOutput ...
  "
  if( ".","~" -eq $fetchOutput){
    $source='*'
  }else{
    $source=$fetchOutput
  }
  "scp  $(if($recursiveFetch){"-r"}) azureuser@$vmIp`:$source $target ..."
  if($recursiveFetch){
    scp -r azureuser@$vmIp`:$source .
  }else{
    scp azureuser@$vmIp`:$source .
  }
  
  if(-not $target -or (Test-Path $target)){"Done."}else{"... but nothing copied."}
  exit
}