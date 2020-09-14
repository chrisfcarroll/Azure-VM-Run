#! /usr/bin/env pwsh -NoProfile
# ----------------------------------------------------------------------------
# The following line is deliberately left blank for powershell help parsing.

<#
.Synopsis
Create-AzMLResources-And-Submit-ForTraining.ps1 can perform one or all of:
  -create the nested sequence of Azure resources needed to run a script on an Azure ML computetarget 
  -create a runconfig file for the script and the resources
  -submit the run

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
          ├── Computetarget (with a vmSize which may include GPU)
          ├── Environments (e.g. PyTorch, TensorFlow, Scikit are available)
          ├── Dataset(s) (optional)
          └── Experiment
              └── runconfig 
                  (which references the computetarget, the optional dataset, 
                   an environment, the experiment and a script)

The Workspace is the primary Machine Learning container. It offers shared 
access to resources, can be accessed from https://ml.azure.com and can 
connect to your local desktop.
- Keeping an empty workspace alive costs about $1 per day.
- To create and destroy a workspace each time you start work typically 
  takes a couple of minutes, and that is the first part of what this 
  script automates.

----------------------------------------------------------------------------
The Steps

[Prequisite] Install az cli tool & ml extensions and be able to access your account

1. All resources are 'kept' together in a ResourceGroup. A ResourceGroup is 
just a management convenience, tied to a location, but costing nothing.

2. In the resourceGroup, you must create a workspace. This will allocate
some storage, and an unused workspace will cost you around `$1 per day. It
may take a couple of minutes to create, and slightly less time to delete.

3. Within the workspace, you create compute instances or compute clusters. 
Clusters have the advantage they can auto-scale down to 0 nodes–i.e. no cost—
when idle.

4. Choose an Experiment name (Defaults to current folder name)

5. Choose an Environment (e.g. TensorFlow, PyTorch, Scikit)

6. Define a Dataset (Offers to create an example from the mnist dataset)

7. Choose a python script to run (Defaults to scripts/train.py)

8. Attach a local folder on your desktop to the workspace

9. Create a runconfig referencing your environment, script, dataset, computetarget

10. Submit the runconfig

--------------------------------------------------------------------------
Not covered by this script:
- Attach an Azure blob container as a Datastore for large datasets and upload files
- Scaffolding your own new Environment
----------------------------------------------------------------------------

Usage:

Create-AzMLResources-And-Submit-ForTraining.ps1 
    [[-resourceGroupName] <StringName> [-location <StringAzureLocation>]] 
    [[-workspaceName] <StringName>] 
    [[-computeTargetName] <StringName> [-computeTargetSize <StringvmSize>]] 
    [[-experimentName] <String>] 
    [-environmentFor <StringMatching> | -environmentName <StringExactName>] 
    [-datasetName <StringName> | -datasetDefinitionFile <path> | -datasetId <StringGuid>]
    [-script <path>] 
    [-attachFolder:$false] 
    [-submit] 
    [-noConfirm]
    [-pricingTier [Standard]]
    [-help] 
    [<CommonParameters>]    

.Example
Create-AzMLResources-And-Submit-ForTraining.ps1 ml1 ml1 ml1 -location uksouth

-creates or confirms a resourceGroup named ml1 in Azure location uksouth,
-creates or confirms a workspace named ml1 in that resourceGroup
-creates or confirms a computetarget ml1 of default size (nc6) in the workspace
-tells you that your experimentName defaults to <current directory>
-lists available Environments 
-then halts telling you to specify an environment.

.Example
Create-AzMLResources-And-Submit-ForTraining.ps1 ml1 ml1 ml1 -environmentFor Tensorflow

-confirms a resourceGroup named ml1 exists in your current default location
-confirms or creates a workspace named ml1 in that resourceGroup
-confirms or creates a computetarget ml1 of default size (nc6) in the workspace
-looks for the alphabetically last environment with 'TensorFlow' in the name
-offers to create a new example datasetDefinitionFile
-asks you whether to attach your folder to the workspace
-looks for a script at the default path scripts/train.py
-if a script is found:
  -offers to create a runconfig file
  -shows you the command line to copy to submit a training run
  
.Example
Create-AzMLResources-And-Submit-ForTraining.ps1 ml1 ml1 ml1 ml1 `
        -environmentFor TensorFlow `
        -datasetName mnist-dataset `
        -script ./scripts/train.py `
        -attachFolder Yes `
        -submit `
        -NoConfirm

Will do these steps:
  -confirms a resourceGroup named ml1 exists in your current default location
  -confirms or creates a workspace named ml1 in that resourceGroup
  -confirms or creates a computetarget ml1 of default size (nc6) in the workspace
  -looks for the alphabetically last environment with 'TensorFlow' in the name
  -offers to create a new example datasetDefinitionFile
  -attaches your folder to the workspace
  -confirms a script at the given path scripts/train.py
  -creates a runconfig file, unless one of the same name exists
  -submits the training run

#>
[CmdletBinding(PositionalBinding=$false)]
Param(
  ##Required for step 2 and further. A new or existing Azure ResourceGroup name.
  ##https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal
  [Parameter(Position=0)][Alias('g')][string]$resourceGroupName, 
  ##Required for step 3 and further. A new or existing workspace, which will hold references to 
  ##your data and computetargets
  [Parameter(Position=1)][Alias('w')][string]$workspaceName,
  ##UA new or existing Azure computetarget to run on. This will scale from 0 to 1 and back to 0 nodes when used
  [Parameter(Position=2)][string]$computeTargetName,
  ##Required to create a runconfig, but defaults to current directory name
  [Parameter(Position=3)][string]$experimentName= (Split-Path (Get-Location) -Leaf),
  ##Usable for step 7. Using this will pick the alphabetically last matching environment,
  ##which will typically be the one with the highest version number
  [ValidateSet('TensorFlow','PyTorch','Scikit','PySpark','CNTK','Minimal','AzureML-Tutorial','TensorFlow-2','TensorFlow-1','PyTorch-1.6')]
    [string]$environmentFor,
  ##Usable for step 7 when you know the exact environmentName you require.
  ##See https://docs.microsoft.com/en-us/azure/machine-learning/resource-curated-environments for Azure-curated environments
  [string]$environmentName,
  ##Name of an existing Dataset to use
  [string]$datasetName,
  ##Name of a file to create a new dataset
  [ValidateScript({Test-Path $_ -PathType 'Leaf'})][string]$datasetDefinitionFile,
  ##Id of an existing Dataset to use
  [string]$datasetId,
  ##The script file (and by implication, the script directory) to submit. Defaults to train.py in the current directory
  [string]$script='train.py',
  ##Confirm attach the current folder to the workspace.
  ##A run submit will probably fail without this
  [switch]$attachFolder=$true,
  ##Whether to submit the script. Otherwise, the generated command line will be shown.
  ##A submittable script requires resourceGroup, workspace, computetarget, experimentName, 
  ##an environment and a script
  [switch]$submit,
  ##Whether to answer yes to all confirmation questions
  [Alias('YesToAll')][switch]$noConfirm,
  ##An Azure region name. Only required when creating a new ResourceGroup at step 2. 
  ##Thereafter the ResourceGroup is all the location you need.
  [string]$location,
  ##Only required when creating a new computetarget at step 4. The pre-selected options are the ones with a GPU
  [ValidateSet('NC6','NC12','NC24','NC6V3','NC12V3','NC24V3','NC6_PROMO','NC12_PROMO','NC24_PROMO', 'NV4AS_V4', 'NV4AS_V4', 'NV8AS_V4')]
    [string]$computeTargetSize='nc6',

  ##Azure pricing tier is combined with computeTargetSize when specifying a new computetarget
  [ValidateSet('Free', 'Shared', 'Basic', 'Standard', 'Premium', 'Isolated')][string]$pricingTier="Standard",
  ##show this help text
  [switch]$help
)
# ----------------------------------------------------------------------------
function Ask-YesNo($msg){return ($noConfirm -or ($Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -eq 0))}
function Ask-YesElseThrow($msg){
  if(-not $noConfirm -and $Host.UI.PromptForChoice("Confirm",$msg, ("&Yes","&No"),1) -ne 0){throw "Halted because you said No"}
}

function Get-DatasetByName($name, $rg, $ws){
  if(-not $rg -or -not $ws){throw "You must specify all of `$name `$rg `$ws without commas. [`$name=$name]"}
  $datasets=(ConvertFrom-Json (
      (az ml dataset list -g $rg -w $ws --query "[?name==`'$name`'].{id:id,name:name}") -join [Environment]::NewLine
    ) -AsHashtable -NoEnumerate)

  return $( if($datasets.Length){ $datasets[0] }else{ $null } )
}

# ----------------------------------------------------------------------------
if((-not $resourceGroupName -and -not $workspaceName) -or $help)
{
  Get-Help $PSCommandPath
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
2. Choose or Create a Workspace $workspaceName
"

if($workspaceName){
  "Looking for existing workspace called $workspaceName ..."
  az ml workspace show --workspace-name $workspaceName --resource-group $resourceGroupName `
        --output table --query "{name:name,resourceGroup:resourceGroup,location:location}"
  if(-not $?){
    "... none found.

    2.1 Create a new Workspace $workspaceName in ResourceGroup $($resourceGroupName)?
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
  write-warning "Halted at step 2. Choose or Create a Workspace.
  "
  exit
}
"✅ OK"

# ----------------------------------------------------------------------------
"
3. Choose or Create a computetarget $computeTargetName $($pricingTier)_$computeTargetSize
"
if($computeTargetName ){
  "Looking for existing computetarget called $computeTargetName ... (please wait a while) ..."
  az ml computetarget show --output table `
            --name $computeTargetName -w $workspaceName -g $resourceGroupName
  if(-not $?){
    "... none found.

    3.1 Create a new computetarget $computeTargetName of size $($pricingTier)_$($computeTargetSize)? 
    (This will be created with min-nodes=0 and max-nodes=1 so it will be free when not in use)"

    Ask-YesElseThrow
    az ml computetarget create amlcompute -n $computeTargetName --min-nodes 0 --max-nodes 1 `
        --vm-size "$($pricingTier)_$computeTargetSize" -w $workspaceName -g $resourceGroupName

    if(-not $?){
      throw "failed at az ml computetarget create amlcompute 
        -n computeTargetName --min-nodes 0 --max-nodes 1 
        --vm-size $($pricingTier)_$computeTargetSize -w $workspaceName -g $resourceGroupName"
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
  write-warning "Halted at 3. Choose or Create a computetarget, because you didn't specify computeTargetName.
  "
  exit
}
"✅ OK"
# ----------------------------------------------------------------------------
"
4. Specify an experimentName $experimentName
"
if($experimentName){"✅ OK"}else{
  write-warning "Stopped at 4. Specify an experimentName because you didn't give one and you blanked out the default name"
  exit
}

# ----------------------------------------------------------------------------
#
# Stop here unless something more has been specified

$noMoreParametersSpecified=  `
  -not (($datasetDefinitionFile, $datasetName, $datasetId, $environmentName, $environmentFor, $submit) -ne "") `
  -and ($experimentName -eq (Split-Path (Get-Location) -Leaf)) `
  -and ($script -eq "scripts/train.py") 

if($noMoreParametersSpecified){

    "You have provisioned the resources needed. 
    To generate a runconfig file, you still need an Environment and a Script (optionally, also a dataset).

    -environmentName | -environmentFor
    [ -DatasetName | -datasetDefinitionFile | -DatasetId ]
    [ -script='scripts/train.py' ]
    [ -submit ]
    [ -NoConfirm ]
    "
}

# ----------------------------------------------------------------------------
"
5. Choose an Environment by name
"
if($environmentName){

  $matchesj=(az ml environment list -w $workspaceName  -g $resourceGroupName `
              --query "[?name==`'$environmentName`')]") -join [Environment]::NewLine
  $matches=ConvertFrom-Json $matchesj -NoEnumerate  -Depth 90
  if(-not $matches.Length){
    write-warning "
    You asked for environment $environmentName , but no such was found.
    To choose an Azure curated environment, instead use 
    -environmentFor TensorFlow | PyTorch | Tutorial | ... instead
    which will find a matching curated Azure ML environment.

    This script doesn't cover creating your own custom environment.

    Halted at 5. Choose an Environment, because your choice wasn't found.
    "
    exit
  }
  $chosenEnvironment= $matches[0]

}elseif($environmentFor){

  "5.1 Looking for an existing environment matching $environmentFor ...
  "
  $matchesj=(az ml environment list -w $workspaceName  -g $resourceGroupName `
              --query "[?contains(name,`'$environmentFor`')]") -join [Environment]::NewLine
  $matches=ConvertFrom-Json $matchesj -NoEnumerate -Depth 90

  if($matches.Length){

    $chosenEnvironment= ($matches | Sort-Object -Property name -Descending | Select -First 1)
    "Found:"
    $matches | Select name
    "6.2 Choosing $chosenEnvironment.name as the alphabetically last match."
    $chosenEnvironment

  }else{
    write-warning "
    You asked for a curated environment matching $environmentFor , but no such was found.
    Here are all known environments available to your workspace:
    "
    az ml environment list -w $workspaceName -g $resourceGroupName --output table
    write-warning "
    Halted at 5. Choose an Environment, because your choice $environmentFor wasn't 
    found. (N.B. the match is case-sensitive).
    "
    exit
  }

}else{
  "Available environments (these are just the GPU enabled ones):
  "
  az ml environment list -w $workspaceName  -g $resourceGroupName --output table --query "[?contains(name,'GPU')]"
  "
  Choose an environment either with 

  -environmentName <existing-environment-name>

  -environmentFor <string-to-search-in-environments-eg-Tensorflow>
  "
  write-warning "Halted at 5. Choose an Environment because you didn't specify either -environmentName or -environmentFor
  "
  exit
}

"✅ OK"

# ----------------------------------------------------------------------------

"
6. Choose a Dataset $datasetName $datasetId or Create one from a file $datasetDefinitionFile
"

$runconfigDataJsonFragment='{}'
$existingDatasetsj= (az ml dataset list -g $resourceGroupName -w $workspaceName `
                      --query "[].{name:name, id:id}") -join [Environment]::NewLine
$existingDatasets= (ConvertFrom-Json $existingDatasetsj -NoEnumerate)

if($datasetName){
  $dataset= $existingDatasets | Where name -eq $datasetName | Select -First 1
  if(-not $dataset){
    "You specified datasetName $datasetName but no dataset was found in workspace $workspace name.
    Existing datasets:"
    $existingDatasets | Select name,id
    "
    If instead you specify no dataset, this script will offer to create an example using the mnist dataset.
    "
    write-warning "
    Halting at step 6. Choose a Dataset because you chose a name for which no dataset exists.
    "
    exit
  }
  $datasetId=$dataset.id
  $datasetName=$dataset.name
  $chosenDatasetFile=$null
}

if(($datasetDefinitionFile) -and (test-path $datasetDefinitionFile)){

  "Registering dataset defined by $datasetDefinitionFile"
  az ml dataset register -f "$datasetDefinitionFile" --skip-validation -w $workspaceName -g $resourceGroupName 
  if(-not $?){throw "failed at az ml dataset register -f $datasetDefinitionFile --skip-validation"}
  if(-not $datasetId){$chosenDatasetFile=$datasetDefinitionFile}
}

if(-not $datasetId -and -not $chosenDatasetFile -and -not $existingDatasets){
  "
  You have not provided a dataset json file. Would you like to create and register 
  a small dataset-Example.json file? (It will use the mnist dataset)
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
            "name": "mnist",
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

if($chosenDatasetFile){
  $datasetSpec= (ConvertFrom-Json ((Get-Content $chosenDatasetFile) -join [Environment]::NewLine) -NoEnumerate -AsHashtable)
  $datasetName=$datasetSpec.registration.name
  $dataset= Get-DatasetByName $datasetName $resourceGroupName $workspaceName
  if($dataset){
    $datasetId=$dataset.id
  }
}

if($datasetId -and $datasetName){
   "Using dataset: name=$datasetName , id=$datasetId"

   $runconfigDataJsonFragment='{
      "dataset-$datasetName":{
        "dataLocation":{
          "dataset":{
            "id": "$datasetId",
            },
          "datapath":null,
        },
        "createOutputDirectories": false,
        "mechanism": "mount",
        "environmentVariableName": "$datasetName"
        }
      }' -replace '\$datasetId', "$datasetId" -replace '\$datasetName', "$datasetName" 

    $runconfigDataJsonFragment

}elseif(-not $chosenDatasetFile -and $existingDatasets.Length){
  "
  NB you have these datasets already defined in your workspace
  "
  $existingDatasets | %{ "name: $($_.name) , id: $($_.id)" } 
}else{
  "Continuing with no dataset"
}

"✅ OK"

# ----------------------------------------------------------------------------
"
7. Choose a script file to run
"

if($script -and (test-path $script)){
  "Found $script"
  $askScript=$null
}elseif(-not $script){
  $askScript="
  You did not specify a script to run.
  Would you like to use an example script which will train on the mnist dataset?"
}else{
  $askScript="
  There is no $script
  Would you like to create an example script which will train on the mnist dataset?"
}

if($askScript){
  $askScript
  if(Ask-YesNo){
    $exampleScript= $(switch -regex ($environmentName){
      "TensorFlow" { "example-tensorflow-train-mnist.py" ; break}
      "PyTorch" { "example-pytorch-train-mnist.py" ; break}
      "Scikit" { "example-scikit-train-mnist.py" ; break}
      default { "example-no-framework.py" }
    })
    $script= "scripts/train.py"
    New-Item scripts -ErrorAction SilentlyContinue
    Copy-Item miscellany/$exampleScript $script
    Get-Content $script
  }else{
    write-warning "Halted at 7. Choose a script file because you didn't specify one and didn't want an example one"
    exit
  }
}
$scriptFile=(Split-Path $script -Leaf)
$scriptDir=(Split-Path $script -Parent)

"✅ OK"
# ----------------------------------------------------------------------------

"
8. Attach the current folder to the workspace $workspaceName in resource group $resourceGroupName ?

Your current path is $(Get-Location)
Your experimentName is $(if($experimentName){$experimentName}else{'<no name given>'})
"

if(test-path ".azureml/"){
  "
  This directory is already attached:"
  get-childitem .azureml/*
  
}elseif($attachFolder -eq 'No'){
  "Not attaching because you said so."
  write-warning "
  A CLI run submit from an unattached folder will probably fail because it
  insists on looking for the nonexistent file ./azureml/conda_dependencies.yml
  "
}elseif(-not $experimentName){
  "Not attaching because you must have an -experimentName to attach a folder, but you blanked it."
}else{
    az ml folder attach -w $workspaceName -g $resourceGroupName --experiment-name $experimentName
    if(-not $?){
      throw "failed at az ml folder attach -w $workspaceName -g $resourceGroupName --experiment-name $experimentName"

    if(Test-Path ".azureml/$experimentName"){
      mv ."azureml/$experimentName" ".azureml/$experimentName.autogenerated"
      "renamed autogenerated experimentName runconfig file"
    }
    if(Test-Path ".azureml/$computeTargetName"){
      mv ."azureml/$computeTargetName" ".azureml/$computeTargetName.autogenerated"
      "renamed autogenerated computeTargetName runconfig file"
    }
  }
}
"✅ OK"

# ----------------------------------------------------------------------------
"
9. Deduce framework and communicator from Environment $chosenEnvironment.name
"
switch -wildcard ($chosenEnvironment.name){

  "*PySpark*"     { $framework = "PySpark" } 
  "*CNTK*"        { $framework = "CNTK" }
  "*TensorFlow*"  { $framework = "TensorFlow" }
  "*PyTorch*"     { $framework = "PyTorch" }
  "*Python*"        { $framework = "Python" }
  Default         { 
          write-warning "Your chosen environment didn't match any of TensorFlow,PyTorch,PySpark,CNTK so setting framework to Python"
          $framework = "Python"
        }
}

switch -wildcard ($chosenEnvironment.docker.baseImage){
  '*intelmpi*'        {$communicator='Mpi'}
  '*openmpi*'         {$communicator='Mpi'}
  '*ParameterServer*' {$communicator='ParameterServer'}
  Default             {$communicator='None' ; write-warning "Didn't find a hint for communicator setting in the Environment basImage name"}
}


"Set framework to $framework and communicator to $communicator"
"✅ OK"

# ----------------------------------------------------------------------------
"
9. Create a runconfig referencing your environment, script, dataset, computetarget
"

"Got:
   ResourceGroup  : $resourceGroupName 
   Workspace      : $workspaceName 
   ComputeTarget  : $computeTargetName 
   Environment    : $($chosenEnvironment.name)
                    $($chosenEnvironment.docker.baseImage)
                    $($chosenEnvironment.python.dependencies)
   Script         : $($(if(test-path $script){"$script"}else{'(no)'}))
   DatasetId?     : $datasetId
   New Dataset?   : $(if($chosenDatasetFile){$chosenDatasetFile}else{'(no)'})
   Experiment Name: $experimentName
   Local directory attached? : $(if(test-path ".azureml/"){'Yes'}else{'No'})
   "

$configDir="$(if(test-path .azureml){'.azureml/'})"
$runconfigName="$experimentName-$computeTargetName"
$runconfigPath="$configDir$runconfigName.runconfig"

if(test-path $runconfigPath){
  "
  runconfig file $runconfigPath already exists.
  "
  If(-not (Ask-YesNo "Delete it?")){
    write-warning "Halted at 9. Create runconfig because one already exists and you said don't delete it."
  }
}
if(test-path "$configDir$runconfigName"){
  "
  A runconfig file named $configDir$runconfigName and will cause $runconfigPath to be ignored.
  "
  If(-not (Ask-YesNo "Delete it?")){
    write-warning "Halted at 9. Create runconfig because $configDir$runconfigName exists and you said don't delete it."
  }
}

if(-not $chosenEnvironment.name -or -not $experimentName -or -not $script){

  "
  You must still specify:"

  if(-not $chosenEnvironment.name){" -environmentMatch or -environmentName. e.g. -environmentMatch TensorFlow"}
  if(-not $experimentName){" -experimentName. Defaults to current folder name."}
  if(-not $script){" -script e.g. scripts/train.py"}
  write-warning "Halting at step 9. Create a runconfig, because you have not specified everything needed to create one."
  exit

}else{

  $content= (Get-Content miscellany/template.runconfig.json) -join [Environment]::NewLine
  $content= $content -replace '\$scriptFile',"$scriptFile"
  $content= $content -replace '\$framework',"$framework"
  $content= $content -replace '\$communicator',"$communicator"
  $content= $content -replace '\$computeTargetName',"$computeTargetName"
  $content= $content -replace '"data": {}',"`"data`": $runconfigDataJsonFragment"
  $content= $content -replace '"environment": {},', "`"environment`": $(ConvertTo-Json $chosenEnvironment -Depth 90) ,"

  Set-Content -Path $runconfigPath -Value $content
}
"✅ OK"

# ----------------------------------------------------------------------------
$runoutputfile="runoutput.json"
if(Test-Path runoutput.json){
  $i=0 ; while(++$i){ if(-not (test-path "runoutput$i.json")){break} }
  $runoutputfile="runoutput$i.json"
}

"
10. Submit $runconfigPath

Command to run:

az ml run submit-script -c $runconfigName -e $experimentName --source-directory `"$scriptDir`" -w $workspaceName -g $resourceGroupName  -t $runoutputfile
"
if($submit){
  "executing ..."
  az ml run submit-script -c $runconfigName -e "$experimentName" --source-directory "$scriptDir" -w $workspaceName -g $resourceGroupName  -t "$runoutputfile"
}else{
  "To submit the run, either use the -submit switch or copy the commandline."
}

# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
