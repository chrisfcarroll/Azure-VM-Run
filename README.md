# `az ml` Quickstart
## Create Azure machine learning resources and submit a training script, from scratch, in 10 minutes

### Q: How can I *script* training runs to run on GPU-enabled computing?

### A: You Could:

-   Use `az ml run submit-script` and learn about the sequence of 7
    (yes, seven) resources & files you will need to create before it works
-   Or go old-school and script a VM and send a repo and data to it over ssh

#### OR You Could:
-   Use these two scripts to do either of those for you in 10 minutes _and_ to help 
    you learn how it all worked at your leisure

#### *Required:*

1. An [Azure Subscription](https://azure.com) with access to create resources
2. [PowerShell](https://github.com/PowerShell/PowerShell)
3. Step zero is for both options is, [install the az cli, and login](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

# Option 1. Using Azure's managed infrastructure for ML training

_NB to copy and paste into a non-powershell shell, replace the backtick line-continuation marks with backslash before pasting_
```
./Create-AzMLResources-And-Submit.ps1 ml1 ml1 ml1 ml1 -location uksouth `
        -environmentFor PyTorch `
        -submit `
        -NoConfirm
```
- will provision: `1` a `Resource Group` with `2` a `Workspace` with `3` a `computetarget` and `4` an `experiment` all named ml1
- Will generate `5` an `example PyTorch script` and `6` an `example dataset` (namely mnist) to train a model and generate `7` a `runconfig` file readable by `az ml run submit-script`
- Will submit it, and stay attached in order to stream the logs to your console.
You can see progress and output at https://ml.azure.com or see status at `az ml run list`

### Yes but what about … ?
The script can take you from the pre-canned example to defining your own datasets, using TensorFlow
or other ML frameworks, specifying a bigger computetarget size, etc. Call the script with `-?` to see more options and much more detail:
```
./Create-AzMLResources-And-Submit.ps1 -?
```

### Show me the GUI?

The GUI way to do this is at https://ml.azure.com, and it can take you through
similar initial steps as this script. You can also use the GUI as a dashboard, 
to see that what the script does appears as expected in your azure account, 
and to see experiment results.

### Tear Down
Keeping a workspace will cost you about $1 per day. Delete the whole resource group or just the workspace with one of:
```
az ml workspace delete -w ml1 -g ml1
az group delete --name ml1
```

# Option 2. Using a VM based on one of Microsoft's Data Science Virtual Machine images

_*Required*_: `ssh` and some basic familiarity with it

_NB to copy and paste into a non-powershell shell, replace the backtick line-continuation marks with backslash before pasting_
```
./Create-AzVM-ForDataSciencePython.ps1 ml1 ml1 -location uksouth `
        -gitRepository https://github.com/chrisfcarroll/TensorFlow-2.x-Tutorials `
        -copyLocalFolder . `
        -commandToRun "python TensorFlow-2.x-Tutorials/11-AE/ex11AutoEncoderMnist.py"  
```
- will create a `Resource Group` and a `Virtual Machine` both named ml1
- will accept the license for the Data Science Virtual Machine image
- will clone the specified git repo to your home directory on the VM
- will copy the local folder specified to your home directory on the VM
- will run the given command

_NB At the point of connecting to a new VM, `ssh` will ask you if you are ok to connect to the new host_

### Yes but what about … ?
The script is intended to be simple. Use your own git repo or local folder, and specify your own `commandToRun`. Call the script with -? to see more options and more detail
```
./Create-AzVM-ForDataSciencePython.ps1 -?
```
To make good use of a VM to offload training, you will want to be familiar with `ssh`, `tmux`, your choice of unix shell, and/or `X-windows`.
The GUI bells & whistles are depicted at https://azure.microsoft.com/en-gb/services/virtual-machines/data-science-virtual-machines/

### Cleanup
Keeping a small VM running will cost you several cents per day. Delete the whole resource group or just the VM with one of:
```
az group delete --name ml1
az vm delete --name ml1
```

# In More Detail

Azure offers two approaches to cloud ML:
1. A [managed service](https://azure.microsoft.com/en-gb/services/machine-learning/) with a “devops” style dashboard that can e.g. gather metrics from your training runs. 
2. Or, just a plain [virtual machine](https://azure.microsoft.com/en-gb/services/virtual-machines/data-science-virtual-machines/). (Well, plainish: it runs X-windows so you can connect to it as a graphical workstation, not just by command line).

## 1. Using Azure's managed infrastructure for ML training

- You can use the script to the very end, or just use parts of it.
- The script defaults to `computetarget size = NC6` which is the cheapset VM size with a GPU
- The script will find an [AzureML curated environment](https://github.com/chrisfcarroll/Azure-az-ml-cli-QuickStart/blob/master/helpful-examples/All%20ML%20Curated%20Environments%20Summary%20as%20at%20September%202020.md) for you if you type part of the name, e.g. Scikit

#### Resources created

What is needed to create, use, & tear down cloud-based ML resources?
<pre>
[Azure Subscription]
  └── ResourceGroup (at a location) : keeps AZ resources together
      └── WorkSpace : keep your ML work and resources together
          ├── Computetarget (with a vmSize which may include GPU)
          ├── Envionment (simplest option is an AzureML curated one)
          ├── Dataset(s) (optional)
          └── Experiment : Keep related runs together
              └── runconfig file
                  (which references the computetarget, the optional dataset, 
                   the experiment and a script)
</pre>
The *workspace* is the primary Machine Learning container. It offers shared 
access to resources, can be accessed from https://ml.azure.com and can 
connect to your local desktop.
- Keeping an empty workspace alive costs about $1 per day.
- To create and destroy a workspace each time you start work typically 
  takes a couple of minutes, and that is the first part of what this 
  script automates.

#### Examples

```
Create-AzMLResources-And-Submit.ps1 ml1 ml1 ml1 ml1
  -datasetName mnist 
  -environmentFor TensorFlow 
  -script ./scripts/train.py
  -attachFolder Yes
```
Will do these steps:
 - Ensure or creates:
     - a resourceGroup, a workspace, a computetarget and an experiment, all called ml1
 - Ensure a dataset named mnist exists in your workspace
 - Pick the alphabetically last environment with name matching TensorFlow
 - Ensure the script ./scripts/train.py exists
 - Attach your current folder to the workspace
 - Generate a runconfig file called ml1-ml1.runconfig
 - Show you the command line to submit the run
_If you add the -submit flag it will also start the run_

```
Create-AzMLResources-And-Submit.ps1 ml1 ml1 ml1 -location uksouth
```
Creates:
  -a resourceGroup named ml1 in Azure location uksouth,
  -a workspace named ml1 in that resourceGroup,
  -a computetarget ml1 of default size (nc6) in the workspace
and then stops, telling you what else you must specify to proceed

## 2. Using an Azure Data Science Virtual Machine' image for ML training or work

- Microsoft have published several “Data Science Virtual Machine” images. The script uses one recommended for CUDA which is:
`microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09`
- The images are preloaded with python, R studio, and a shed-load of python ML frameworks.
- The script defaults to VM size = NC6 which is the cheapset VM size with a GPU
- Advantages of a VM over a computetarget: 
  - Interactive as well as batch. You can SSH to the VM or connect from X-windows, so it's a desktop experience
  - Often (in my experience) faster startup than a managed computetarget, and no waiting in a queue for resources
- All the parameters `-gitRepository  -copyLocalFolder -commandToRun` will run with current directory as the Home directory, so copied or git-cloned folders can be referenced with a simple relative path, as in the example given above.

## Addenda

### Comments on Azure GPU options

A computetarget is a VM or at least it is specified with a VM size. You'll want to be sure to use a VMSize that includes a GPU.

*TL;DR:* Use a N-series VM for the NVidia Tesla GPUs. 
- The oldest hardware - NC series - now has 50% off promo options, but these seem not to be accessible for ML workspace setup. 
- Note also that on a new account you may have to first request access to the larger VMs, which you can do via the GUI at https://ml.azure.com.

Choose from 
- $0.60 per hour for NC6Promo - Tesla K80 (2015 design, 2496 cores @ 560MHz-875MHz 24GB GDDR5)
- $1.20-$2.50 per hour for NC12 or NC24 Promo - 2 or 4 x Tesla K80
  (2015 design, 2496 cores @ 560MHz-875MHz 24GB GDDR5)
- $7-15 per hour for NC12v3 - NC24v3 - 2-4 x Tesla V100 
  (640TensorCores,5120Cuda Cores, 32-64GB HBM2 memory)

### MS Docs on:
- [N series GPU enabled virtual machines](https://azure.microsoft.com/en-gb/pricing/details/virtual-machines/series/)
- [GPU optimized virtual machine sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-gpu?toc=/azure/virtual-machines/linux/toc.json&bc=/azure/virtual-machines/linux/breadcrumb/toc.json)

### MacOs X-Windows connections
- https://www.xquartz.org/
- https://serverfault.com/questions/273847/what-does-warning-untrusted-x11-forwarding-setup-failed-xauth-key-data-not-ge
- https://serverfault.com/questions/422908/how-can-i-prevent-the-warning-no-xauth-data-using-fake-authentication-data-for
