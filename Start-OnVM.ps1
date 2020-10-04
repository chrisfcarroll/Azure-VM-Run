#! /usr/bin/env pwsh -NoProfile
# ----------------------------------------------------------------------------
# Start-OnVM.ps1 runs a local command on an Azure VM. 
# Synopsis: See bottom of file ☟
#
[CmdletBinding(PositionalBinding=$false)]
Param(
  ##Command to execute after copyFromLocal (if any) and after cloning gitRepository (if any)
  ##The command will run in a detached tmux session
  ##The command will be passed to bash, so if it is a python script then use e.g. "python script.py"
  [Parameter(Position=0)][string]$commandToRun,

  ##A python script to run after copyFromLocal (if any) and after cloning gitRepository (if any)
  ##and after commandToRun (if any).
  ##The command will run in a detached tmux session and is assumed to be a Python 
  ##script, which will be run with "python -u <pythonCommandToRun>"
  [Parameter][string]$pythonCommandToRun,

  ##Path of a folder or files on your local machine to copy to the VM.
  ##scp is used, so scp's semantics are followed:
  ##If -copyFromLocal is not simply a subdirectory of the current working folder then
  ##it will be copied to a folder under the home directory with the same name as the
  ##last part of the folder's path, e.g:
  ## -copyFromLocal "/this/path/is/notasubdirectory" will be copied to "~/notasubdirectory/"
  ## -copyFromLocal "./that/asubdirectory"           will be copied to "~/asubdirectory/"
  [Parameter(Position=1)][ValidateScript({Test-Path $_ })][string]$copyFromLocal,

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

  ##The predefined conda environment which will be use if -imageUrn is a 
  ##'microsoft-dsvm:ubuntu-1804:...' image.
  ## Defaults to 'py37_tensorflow'
  ##
  ##If -imageUrn is a linuxdsvmubuntu image then this parameter defaults to empty,
  ##which will be ignored
  [ValidateSet(
      'azureml_py36_automl',
      'azureml_py36_pytorch',
      'azureml_py36_tensorflow',
      'py37_default',
      'py37_pytorch',
      'py37_tensorflow')]
  [string]$condaPredefinedEnvName,

  ##The packages that will be included in the default (that is, set in .bashrc)
  ##conda environment if the -imageUrn is a linuxdsvmubuntu image.
  ##Defaults to common machine learning packages : "tensorflow-gpu=2.2 pytorch=1.5 scikit-learn matplotlib pillow"
  ##
  ##If -imageUrn is a 'microsoft-dsvm:ubuntu-1804:...' image then this parameter defaults to empty, 
  ##which will be ignored
  [string]$condaEnvironmentSpec,

  ##If true, apply -condaPredefinedEnvName and/or -condaEnvironmentSpec and/or -pipPackagesToUpgrade
  ##just as if creating the VM for the first
  [switch]$resetCondaEnvironment,

  ##Packages to pip upgrade after setting up -condaEnvironmentSpec. Use this for frameworks such 
  ##as pytorch & tensorflow which are under rapid development and for which -condaEnvironmentSpec
  ##doens't provide a recent enough package.
  ##Example: -pipPackagesToUpgrade "tensorflow-gpu==2.3 matplotlib pillow"
  [string]$pipPackagesToUpgrade,

  ##Required. A new or existing Azure ResourceGroup name.
  ##https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal
  [Alias('g')][string]$resourceGroupName, 

  #Azure location. Only needed if you are creating a new Resource Group
  [string]$location,

  ##Image urn to use for the VM
  ##- microsoft-dsvm:ubuntu-1804 series images are probably more recent and have predefined conda enviroments for each of
  ##pytorch, tensorflow, or neither.
  ##- microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu don't. During setup, $condaEnvironmentSpec will be 
  ##used to define a conda environment
  [ValidateSet(
    'microsoft-dsvm:ubuntu-1804:1804:20.07.06',
    'microsoft-dsvm:ubuntu-1804:1804-gen2:20.07.06',
    'microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09',
    'microsoft-dsvm:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.02')]
  [string]$imageUrn='microsoft-dsvm:ubuntu-1804:1804:20.07.06',


  #Required. Name of the VM to create or confirm
  [string]$vmName='DSVM',

  ##Size of the VM to create
  [ValidateSet(
    "NV6", "NV12", "NV24",
    "NV6_Promo", "NV12_Promo", "NV24_Promo",
    "NC6", "NC12", "NC24", "NC24r",
    "NC6_Promo", "NC12_Promo", "NC24_Promo", "NC24r_Promo",
    "NV4as_v4", "NV8as_v4", "NV16as_v4", "NV32as_v4",
    "NV6s_v2", "NV12s_v2", "NV24s_v2", "NV12s_v3", "NV24s_v3", "NV48s_v3",
    "NC6s_v3", "NC12s_v3", "NC24rs_v3", "NC24s_v3",
    'B1s')]
  [string]$vmSize='NC6_PROMO',

  ##Use this switch to avoid waiting to accept an image license you have already accepted
  [switch]$licensedAlreadyAccepted,

  ##Whether to answer yes to all questions and continue without user confirmation
  [Alias('yes')][switch]$noConfirm,

  ##Set this to first halt all running sessions - that is, all tmux and tails.
  ##Can be used alone, or with other parameters. If used with -commandToRun, then
  ##halt is done first, then the commandToRun
  [switch]$haltPrevious,

  ##show this help text
  [switch]$help
)
# ----------------------------------------------------------------------------

function main{

  Help-AndExit-IfHelp
  HelpSummary-AndMaybeExit-IfNoParameters
  Ensure-AzCli-ElseExit
  Ensure-AzLoggedIn-ElseAzLogin
  Ensure-ResourceGroup
  Ensure-VM-ElseCreateAndPrepareNewVM
  CopyLocalFilesIfWanted
  GitCloneIfWanted
  RunAndTailCommandsIfWanted
  FetchOutputsIfWanted
  exit
}

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

$summaryHelp= -not $noConfirm -and -not $haltPrevious -and -not $resetCondaEnvironment `
              -and -not ($resourceGroupName,$fetchOutput,$copyFromLocal,$commandToRun,$pythonCommandToRun -gt " " )

if($summaryHelp){

  "
  Start-OnVM.ps1 runs a local command on an Azure VM. 

  Start-OnVM.ps1  [[-commandToRun] <String command and args> ] 
                  [[-pythonCommandToRun] <String file.py and args>] 
                  [[-copyFromLocal] <Local path> [-recursiveCopy] ] 
                  [[-fetchOutput] <Path> [-recursiveFetch ]]
                  [-recursiveBothCopyAndFetch]
                  [[-gitRepository] <Uri to a git repo to clone onto the VM>]  
                  [-condaPredefinedEnvName <String>] [-condaEnvironmentSpec <String>]
                  [-resetCondaEnvironment] 
                  [-pipPackagesToUpgrade <String>] 
                  [-resourceGroupName <String> [-location <Azure Location ID e.g. uksouth>]]
                  [-imageUrn <String>] 
                  [-licensedAlreadyAccepted]
                  [-vmName <String>] [-vmSize <String>] 
                  [-noConfirm] 
                  [-haltPrevious]
                  [-help]
                  [<CommonParameters>]

  • Start-OnVM.ps1 with no parameters will start a VM if you have a default location set.
  • For more help, use Start-OnVM.ps1 -help

  You can skip this confirmation with Start-OnVM.ps1 -noConfirm"
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
  az login
}

# ----------------------------------------------------------------------------
if(-not $resourceGroupName)
{
  $resourceGroupName= (az configure -l --query "[?name=='group'].value|[0]")
  if($resourceGroupName){ $resourceGroupName=$resourceGroupName.Trim('"') }
  elseif($noConfirm    ){ $resourceGroupName="VMRun" }
}
if(-not $location)
{
  $location=(az configure -l --query "[?name=='location'].value|[0]")
  if($location){$location= $location.Trim('"')}
}

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

    az configure --defaults location=uksouth group=VMRun
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

if($imageUrn -match '-gen2' -and -not ($vmSize -like '*v3') -and -not ($vmSize -like 'B*'))
{
  write-warning "You chose image=$imageUrn and VM Size=$vmSize but your image 
  looks like it's a generation 2 name, and $vmSize may not support gen2.
  NC v2 and v3, and NV v3 do support gen2."
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
5. Connect to the VM, choose or create conda environment, download git repo, copy local folder
"

if($isNewlyCreatedVM)
{
  "
  You may have to wait a minute or more before the VM is ready to accept connections ...
  "
  do{
    'Waiting for VM to accept connections ...'
    ssh azureuser@$vmIp uname -a
    $didConnect= $?
    if(-not $didConnect){sleep 10}
  }until($didConnect)
}

if( ($isNewlyCreatedVM -or $resetCondaEnvironment) `
    -and -not $condaPredefinedEnvName -and -not $condaEnvironmentSpec)
{
  $cmd="curl -sH 'Metadata: true' 'http://169.254.169.254/metadata/instance?api-version=2020-06-01' " +
       "| jq '.compute.storageProfile.imageReference | .publisher + \`":\`" + .sku'"
  $imagesku=$(ssh azureuser@$vmIp $cmd)
  if($imagesku -match '"microsoft-ads:linuxdsvmubuntu"'){
    $condaEnvironmentSpec="tensorflow-gpu=2.2 pytorch=1.5 scikit-learn matplotlib pillow"
    "You choose an image matching $imagesku`. Will create conda environment $condaEnvironmentSpec"
  }
  elseif($imagesku -match '"microsoft-dsvm:1804"'){
    $condaPredefinedEnvName="py37_tensorflow"
    "You chose an image matching $imagesku`. Will set pre-existing conda environment $condaPredefinedEnvName"
  }
}


if($isNewlyCreatedVM -or $resetCondaEnvironment){
  "
  Setting .bashrc to load and run anaconda in non-interactive shells
  "
  ssh -q azureuser@$vmIp /anaconda/bin/conda init bash
  ssh -q azureuser@$vmIp sed -i "'s/\*) return;;/*) ;;#dont return/'" .bashrc

  if($condaPredefinedEnvName){
    "Setting conda environment $condaPredefinedEnvName"
    ssh -q azureuser@$vmIp "conda activate $condaPredefinedEnvName && echo `"conda activate $condaPredefinedEnvName`" >> .bashrc"
  }
  else{
    "
    Creating conda environment for $condaEnvironmentSpec
    "
    ssh -q azureuser@$vmIp "conda create -n vm $condaEnvironmentSpec --yes"
    ssh -q azureuser@$vmIp 'echo "conda activate vm" >> .bashrc'
  }
}

if($pipPackagesToUpgrade){
  "
  Running pip install $pipPackagesToUpgrade --upgrade ...
  "
  ssh -q azureuser@$vmIp "python --version && python -m pip install $pipPackagesToUpgrade --upgrade"
}

$sshOK=@()


#----------------------------------------------------------------------
$recursiveCopy= $recursiveCopy -or $recursiveBothCopyAndFetch
if($copyFromLocal){
  if($copyFromLocal -eq "."){
    $source="*"
  }else{
    $source=$copyFromLocal
  }
  "
  5.1 Copying $source to VM $(if($recursiveCopy){"recursively"})
  
  scp  $(if($recursiveCopy){"-r"}) $source azureuser@$vmIp`: ..."  
  if($recursiveCopy){
    scp -q -r $source azureuser@$vmIp`:
    $sshOK += ,$(if($?){"✅ copyFromLocal"}else{"❌ copyFromLocal errored"})
  }else{
    scp -q $source azureuser@$vmIp`:
    $sshOK += ,"✅ copyFromLocal" 
    # exit code will be > 0 for non-recursive copy just because of subdirectories
  }
}

if($gitRepository){
  "
  5.2 Git cloning $gitRepository ...
  "
  ssh -q azureuser@$vmIp "git clone $gitRepository"
  $sshOK += ,$(if($?){"✅ git cloned"}else{"❌ git clone errored"})
}
"✅ OK"

# --------------------------------------------------------------------------

if($haltPrevious){
  "
  Halting previous sessions, if any ..."
  ssh -q azureuser@$vmIp 'tmux kill-server ;  pkill tail'
}

# --------------------------------------------------------------------------
if($commandToRun -or $pythonCommandToRun){

  $logName= "$vmName-" + [DateTime]::Now.ToString('yyyyMMdd-HHmm-ssff') + '.log'

  "
  6. Run commands in a tmux session ...
     $commandToRun 
     $pythonCommandToRun
     Use tmux to create/detach from long running jobs.
     Detach from the tmux session by using the key sequence Ctrl-B d
     Reattach to its console with:
     > ssh azureuser@$vmIp -t tmux attach
  "

  if($commandToRun)
  {
    if($commandToRun -match "^\w+\.py( |$)")
    {
      write-warning "Did you mean `"-pythonCommandToRun $commandToRun`" rather than `"-commandToRun ...`" ?"
    }
    elseif($commandToRun -match "^python \w+\.py( |$)")
    {
      write-warning "hint: `"python -u ...`" instead of just `"python ...`" will give you a real-time view of output."
    }

    #tmux bash <command> seems better than just tmux <command>, because it can run a full pipeline
    $tmuxbashcommand= "bash -ilc `'$($commandToRun -replace '"','\"' -replace "'","\'") 2>&1 | tee -a $logName `'"
    ssh -q azureuser@$vmIp -t tmux new-session -d $tmuxbashcommand
    $sshOK += ,$(if($?){"✅ Ran command."}else{"❌ start command errored"})
    $sshOK += ,"✅ Logging to : $logName"
  }

  if($pythonCommandToRun)
  {
    $tmuxbashpythoncommand= "bash -ilc `'python -u $($pythonCommandToRun -replace '"','\"' -replace "'","\'") 2>&1 | tee -a $logName `'"
    ssh -q azureuser@$vmIp -t tmux new-session -d $tmuxbashpythoncommand
    $sshOK += ,$(if($?){"✅ Ran python command."}else{"❌ start python command errored"})
    $sshOK += ,"✅ Logging to : $logName"
  }
}

#--------------------------------------------------------------------------
if($logName)
{
  "
  Tailing the command. Press Ctrl-C to disconnect. To reattach use:
  > ssh azureuser@$vmIp tail -f $logName
  "
  sleep 1
  try{ ssh -q azureuser@$vmIp tail -f $logName }
  catch{"
        (stopped tailing)
        "}
}

# --------------------------------------------------------------------------
$recursiveFetch= $recursiveFetch -or $recursiveBothCopyAndFetch
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
    scp -q -r azureuser@$vmIp`:$source .
  }else{
    scp -q azureuser@$vmIp`:$source .
  }
}

$sshOK

"VM is ready for you to connect with ssh:

> ssh azureuser@$vmIp
"
<#
.Synopsis
Start-OnVM.ps1 runs a local command on an Azure VM. 

By default it will:
  -first find or create a Virtual Machine and a Azure resource group to hold it.
  -use the cheapest Azure hardware with a GPU, namely NC6_PROMO 
  -use a microsoft-dsvm:ubuntu-1804 image, preloaded for data science and ML training
  -Set the conda environment to python 3.7 with tensorflow

Depending on parameters passed it will then:
  -copy files to the VM. Copy defaults to not recursive.
  -clone a git repo on the VM
  -set a commmand and/or a python command running
  -change or update the conda enviroment and/or use pip to install or ugrade packages
  -tail the output of the command until you press Ctrl-C
  -fetch files from the VM back to your machine

Start-OnVM.ps1  [[-commandToRun] <String command and args> ] [-pythonCommandToRun] <String file.py and args>] 
                [[-copyFromLocal] <Local path> [-recursiveCopy] ] 
                [[-fetchOutput] <Path> [-recursiveFetch ]]
                [-recursiveBothCopyAndFetch]
                [[-gitRepository] <Uri to a git repo to clone onto the VM>]  
                [-condaPredefinedEnvName <String>] [-condaEnvironmentSpec <String>]
                [-resetCondaEnvironment] 
                [-pipPackagesToUpgrade <String>] 
                [-resourceGroupName <String> [-location <Azure Location ID e.g. uksouth>]]
                [-imageUrn <String>] 
                [-licensedAlreadyAccepted]
                [-vmName <String>] [-vmSize <String>] 
                [-noConfirm] 
                [-haltPrevious]
                [-help]
                [<CommonParameters>]

More detail : https://github.com/chrisfcarroll/Azure-VM-Run

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

7. Tail the command until you press Ctrl-C

8. Copy output from the VM back to your local working directory

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
- image = microsoft-dsvm:ubuntu-1804:1804:20.07.06
- size  = NC6_Promo
- name = DSVM
- resourceGroup Name= VMRun

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
Start-OnVM.ps1 -python main.py -copy . fetch . -location uksouth
-First creates or confirms the Azure resources required:
  -a resourceGroup named VMRun in Azure location uksouth
  -a VM named DSVM
    - with default size : NC6_PROMO
    - with default image : microsoft-dsvm:ubuntu-1804:1804
    -accepts the license for the image
    -sets the conda environment to python 3.7 with tensorflow

-Then
  -copies your current working directory (without subdirectories) to the VM
  -runs the given command "python main.py" on the VM in a tmux session
  -tails the command until you press Ctrl-C
  -copies the VM's home folder back to your local current working directory

.Example
Start-OnVM.ps1 
    "python -u TensorFlow-2.x-Tutorials/11-AE/ex11AE.py"
    -gitRepository https://github.com/chrisfcarroll/TensorFlow-2.x-Tutorials
    -fetchOutput TensorFlow-2.x-Tutorials/11-AE/images
    -recursiveFetch
    -condaEnvironmentSpec "python=3.8 tensorflow-gpu=2.2 scikit-learn matplotlib pillow"
    -pipPackagesToUpgrade tensorflow-gpu==2.3 matplotlib

-First creates or confirms the Azure resources required:
  -a resourceGroup named VMRun
  -a VM named DSVM
    -with default size : NC6_PROMO
    -with default image : microsoft-dsvm:ubuntu-1804:1804
    -accepts the license for the image
-Then
  -creates a conda/python environment with the initial spec given
  -runs pip install --upgrade with the packages given
  -clones the given git repo into the path ~/TensorFlow-2.x-Tutorials
  -runs the given command in a detached tmux session
  -tails the command until you press Ctrl-C
  -copies the remote directory ~/TensorFlow-2.x-Tutorials/11-AE/images to local path ./images/

.Example
Start-OnVM.ps1 
    -vmName MyOtherVMName 
    -resourceGroupName MyRGName -location uksouth
    -vmSize NC24_PROMO
    -condaPredefinedEnvName py37_pytorch
    -pipPackagesToUpgrade matplotlib
    -copy workingdir -recursiveCopy

- creates or confirms the Azure resources required
- sets up the conda/python environnment specified
- copies workingdir and subdirectories to the VM
- and stops.
This can be used to 'warm-start' a VM.

.Example
Start-OnVM.ps1 -fetchOutput some/outputs/ recursiveFetch

-attempts to find and connect to a running VM with the default name, DSVM, 
-recursively copies the remote directory ~/some/outputs/ to a local directory ./outputs/

#>
