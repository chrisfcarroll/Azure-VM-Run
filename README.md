# Azure VM Run
## Run your scripts on gpu powered VMs & compute resources on Azure, from scratch, in 5 minutes
### `az vm` and `az ml compute` Quickstart

### Q: How can I *script* tasks to run on GPU-enabled computing on Azure?

### A: You Could:

-   Use `az ml run submit-script` and learn about the sequence of 8
    (yes, eight) resources & files you will need to create before it works
-   Create a VM, clone a repo and/or copy data to it over ssh, and copy the results back afterwards

### OR You Could:
-   Use these two scripts to do either of those two tasks for you in 5 minutes
    _and_ help you learn at your leisure how it all worked.

#### *Required:*

1. An [Azure Subscription](https://azure.com) with access to create resources.
   _NB This will work on a Free Tier subscriptions but provisioning will be slower
   and you won't have any GPU._
2. [PowerShell](https://github.com/PowerShell/PowerShell)
3. Step zero for both options is, [install the az cli, and login](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)


# Option 1. Virtual Machine with GPU and ML tooling

_*Required*_: `ssh` and some basic familiarity with it

```
Start-OnVM.ps1 somecommand     -copy . fetch . -location uksouth
# or, name a python script:
Start-OnVM.ps1 -python main.py -copy . fetch . -location uksouth
```

- First creates or confirms the Azure resources required:
  - a resource group (default name VMRun) in Azure location uksouth
  - a VM (default name DSVM)
    - with default size: NC6_PROMO
    - with default image: microsoft-dsvm:ubuntu-1804:1804
    - accepts the license for the image
    - sets the conda environment to python 3.7 with tensorflow
- Then
  - copies your current working directory (without subdirectories) to the VM
  - runs the given command on the VM in a tmux session
  - tails the command until you press Ctrl+C
  - copies the VM's home folder back to your local current working directory

_NB At the point of connecting to a new VM, `ssh` will ask you if you are ok to connect to the new host_

### Yes but what about … ?
See `Start-OnVM.ps1 -help` for more options and details including conda environments, pip, cloning repos, recursive copy and fetch etc.

To make good use of a VM to offload training, you will want to be familiar with `ssh`, `tmux`, 
your choice of unix shell, and/or `X-windows`. The GUI bells & whistles are portrayed at 
https://azure.microsoft.com/en-gb/services/virtual-machines/data-science-virtual-machines/

### Tear Down
Keeping an N-series VM running may cost you $10-30 per day. Delete the whole resource group or just the VM with one of:
```
az vm delete --name DSVM
az group delete --name VMRun
```
_Don't get stung! Check in your Azure portal that all resources have been deleted._

# Option 2. Azure's managed offering for ML

_NB to copy and paste into a non-powershell shell, replace the backtick line-continuation marks with backslash before pasting_
```
Start-OnComputeTarget.ps1 ml1 ml1 ml1 ml1 -location uksouth `
        -environmentFor PyTorch `
        -submit `
        -NoConfirm
```
- will provision: `1.` a `Resource Group` with `2.` a `Workspace` and `3.` a `computetarget` and configure `4.` an `experiment`, all named ml1
- will choose `5.` an `Environment` for PyTorch, then generate `6.` an `example PyTorch script` and `7.` an `example dataset` (namely mnist) to train a model and finally generate `8.` a `runconfig` file readable by `az ml run submit-script`
- will submit the script and stay attached, streaming the logs to your console. You can see progress and output at https://ml.azure.com or see status at `az ml run list`

### Yes but what about … ?
The script can take you from the pre-canned example to defining your own datasets, using [other ML frameworks (TensorFlow etc)](https:helpful-examples/All%20ML%20Curated%20Environments%20Summary%20as%20at%20September%202020.md), specifying a bigger computetarget size, etc. Call the script with `-?` to see more options and more detail.
```
./Start-OnComputeTarget.ps1 -?
```

### Show me the GUI?

The GUI way to do this is at https://ml.azure.com, and it can take you through
similar initial steps as this script. You can also use the GUI as a dashboard, 
to see that what the script does appears as expected in your azure account, 
and to see experiment results.

### Tear Down
Keeping a workspace running may cost $10-$30 or more per day. Delete the whole resource group or just the workspace with one of:
```
az ml workspace delete -w ml1 -g ml1
az group delete --name ml1
```
_Don't get stung! Check in your Azure portal that all resources have been deleted._

# In More Detail

Azure offers two viable approaches to cloud ML:
1. A plain [virtual machine](https://azure.microsoft.com/en-gb/services/virtual-machines/data-science-virtual-machines/) with NVida GPU acceleratora. Well, plainish: it's a complete graphical workstation with X-windows & R-studio etc etc, not just a command line with Anaconda and Python.
2. A [managed service](https://azure.microsoft.com/en-gb/services/machine-learning/) with a “devops” style dashboard that can e.g. gather metrics from your training runs, provide a shared workspace for data, results, and experiment history. 

### Option 1. Using Microsoft's Data Science Virtual Machine' image for ML training or work
Microsoft have published several “Data Science Virtual Machine” images. The recommended image runs on Ubuntu and has NVidia CUDA support and GPU management. 
- The images are preloaded with python, R studio, and a shed-load of python ML frameworks.
- Pre-installed Conda environments are python 3.7 or 3.8 with tensorflow or pytorch
- The script defaults to the cheapset VM size with a GPU
- Advantages of a VM over a computetarget: 
  - Interactive as well as batch. You can SSH to the VM or connect from X-windows, so it's a desktop experience
  - Often (in my experience) faster startup than a managed computetarget, and no waiting in a queue for resources
  -Almost certainly cheaper, possibly a lot cheaper. You only need the VM for runs, you take respponsibility for keeping copies of data, results and history.

### Option 2. Using Azure's managed infrastructure for ML training

The managed infrastructure product is more focussed on GUI than on scripting. To script successfully, you need to know exactly the sequence of resources you must create & tear down managed cloud-based ML resources.

#### Resources created for managed ML
<pre>
[Azure Subscription]
  └── ResourceGroup (at a location) : keeps AZ resources together
      └── WorkSpace : keep your ML work and resources together
          ├── Computetarget (with a vmSize which may include GPU)
          ├── Environment (simplest option is an AzureML curated one)
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

#### This Script will Take You Through These Steps

1. Create a Resource Group. This is Azure's way to 'keep together' related
   resources. It is tied to an azure location and is free.

2. In the Resource Group, create a Workspace. This will allocate
   some storage, and an unused workspace will cost you around $1 per day. It
   may take a couple of minutes to create, and slightly less time to delete.

3. Within the Workspace, create a computetarget. This can be made to
   auto-scale down to 0 nodes–i.e. no cost—when idle.

4. Choose an Experiment name. This defaults to current folder name.

5. Choose an Environment. Use PowerShell tab-completion to see some options.
   An environment is typically a reference to a docker image with python and 
   ML libraries installed e.g. TensorFlow, PyTorch, Scikit and others.

6. Optionally, choose or register a Dataset.
   The script offers to create an example mnist dataset.

7. Choose a python Script to run
   Defaults to ./train.py. The script offers to create an example one.

8. Attach a local folder on your desktop to the Workspace.

9. Create a runconfig referencing your environment, script, dataset, computetarget.

10. Submit the runconfig

--------------------------------------------------------------------------
Not covered by this script:
- Attach an Azure blob container as a Datastore for large datasets and uploads
- Creating your own new Environment definition
----------------------------------------------------------------------------

#### Examples

```
Start-OnComputeTarget.ps1 ml1 ml1 ml1 ml1
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
Start-OnComputeTarget.ps1 ml1 ml1 ml1 -location uksouth
```
Creates:
  -a resourceGroup named ml1 in Azure location uksouth,
  -a workspace named ml1 in that resourceGroup,
  -a computetarget ml1 of default size (nc6) in the workspace
and then stops, telling you what else you must specify to proceed

## Addenda

### Azure GPU options

A computetarget is a VM or at least it is specified with a VM size, so the machine and GPU options are the same for both options. You'll want to be sure to use a VMSize that includes a GPU.

*TL;DR:* Use a N-series VM for the NVidia Tesla GPUs. 
- The oldest hardware - NC series - now has 50% off promo options
- On a new account you may have to first request access to the larger VMs. You can do this via the GUI at https://ml.azure.com or via the URL you get in an error message telling you to request a quota change.

Choose from 
- $0.60 per hour for NC6Promo with Tesla K80 
- $1.20-$2.50 per hour for NC12 or NC24 Promo - 2 or 4 x Tesla K80
  (2015 design, 2496 cores @ 560MHz-875MHz 24GB GDDR5)
- $7-15 per hour for NC12v3 - NC24v3 - 2-4 x Tesla V100 
  (640TensorCores,5120Cuda Cores, 32-64GB HBM2 memory)

- _Don't pay for dual or quad GPU machines unless your code can use them_
- _You will have storage charges as well as VM charges. Bigger VMs have more expensive storage_

* Tesla K80 : A 2014 Server Kepler design (One K80 = two GK210s each with 12GB GDDR5)
* Tesla M60 : A 2015 Workstation GPU Maxwell design 
* Tesla P100: A 2016 Datacentre Pascal design
* Tesla V100: A 2017 Datacentre Volta design

| VM Size | Has GPU | NVida GPU Rating | GPU MHz/Cores | GPU RAM | VCPUs | VM Ram | $ per hour |
|---------|---------|------------------|---------|-----------|---------|-------|---------|
| NC6 | 1x Tesla K80 | 8 TFlops | 560-875MHz 2496 cores | 24GB GDDR5 | 6 cpucores | 56GB | $1 per hr |
| NC12 | 2x Tesla K80 | 2x 8 TFlops | 560-875MHz 2496 cores | 24GB GDDR5 | 12 cpucores | 112GB | $2 per hr |
| NC24 | 4x Tesla K80 | 4x 8 TFlops | 560-875MHz 2496 cores | 24GB GDDR5 | 24 cpucores | 224GB | $5 per hr |
| NC24r | 4x Tesla K80 | 4x 8 TFlops | 560-875MHz 2496 cores | 24GB GDDR5 | 24 cpucores | 224GB | $5 per hr |
| NC6 Promo | 1x Tesla K80 | 8 TFlops | 560-875MHz 2496 cores | 24GB GDDR5 | 6 cpucores | 56GB | $0.60 per hr |
| NC12 Promo | 2x Tesla K80 | 2x 8 TFlops | 560-875MHz 2496 cores | 24GB GDDR5 | 12 cpucores | 112GB | $1 per hr |
| NC24 Promo | 4x Tesla K80 | 4x 8 TFlops | 560-875MHz 2496 cores | 24GB GDDR5 | 24 cpucores | 224GB | $2 per hr |
| NC24r Promo | 4x Tesla K80 | 4x 8 TFlops | 560-875MHz 2496 cores | 24GB GDDR5 | 24 cpucores | 224GB | $2 per hr |
| NC6s v3 | 1x Tesla V100 | 15TFlops / 112 TFlops | 640 TensorCores 5120 CUDA cores | 16GB HBM2 | 6 cpucores | 112GB | $3 per hr |
| NC12s v3 | 2x Tesla V100 | 2x 15TFlops / 112 TFlops | 640 TensorCores 5120 CUDA cores | 32GB HBM2 | 12 cpucores | 224GB | $7 per hr |
| NC24s v3 | 4x Tesla V100 | 4x 15TFlops / 112 TFlops | 640 TensorCores 5120 CUDA cores | 64GB HBM2 | 24 cpucores | 448GB | $14 per hr |
| NC24rs v3 | 4x Tesla V100 | 4x 15TFlops / 112 TFlops | 640 TensorCores 5120 CUDA cores | 64GB HBM2 | 24 cpucores | 448GB | $15 per hr |
| NV6 | 1x Tesla M60 | 9 TFlops | 4096 CUDA cores | 16GB GDDR5 | 6 cpucores | 56GB | $1 per hr |
| NV12 | 2x Tesla M60 | 2x 9 TFlops | 4096 CUDA cores | 16GB GDDR5 | 12 cpucores | 112GB | $3 per hr |
| NV24 | 4x Tesla M60 | 4x 9 TFlops | 4096 CUDA cores | 16GB GDDR5 | 24 cpucores | 224GB | $6 per hr |
| NV6 Promo | 1x Tesla M60 | 9 TFlops | 4096 CUDA cores | 16GB GDDR5 | 6 cpucores | 56GB | $0.60 per hr |
| NV12 Promo | 2x Tesla M60 | 2x 9 TFlops | 4096 CUDA cores | 16GB GDDR5 | 12 cpucores | 112GB | $1 per hr |
| NV24 Promo | 4x Tesla M60 | 4x 9 TFlops | 4096 CUDA cores | 16GB GDDR5 | 24 cpucores | 224GB | $3 per hr |
| NV12s v3 | 1x Tesla M60 | 9 TFlops | 4096 CUDA cores | 16GB GDDR5 | 12 cpucores | 112GB | $1 per hr |
| NV24s v3 | 2x Tesla M60 | 2x 9 TFlops | 4096 CUDA cores | 16GB GDDR5 | 24 cpucores | 224GB | $2 per hr |
| NV48s v3 | 4x Tesla M60 | 4x 9 TFlops | 4096 CUDA cores | 16GB GDDR5 | 48 cpucores | 448GB | $5 per hr |

### MS Docs on:
- [N series GPU enabled virtual machines](https://azure.microsoft.com/en-gb/pricing/details/virtual-machines/series/)
- [GPU optimized virtual machine sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-gpu?toc=/azure/virtual-machines/linux/toc.json&bc=/azure/virtual-machines/linux/breadcrumb/toc.json)

### MacOs X-Windows connections
- https://www.xquartz.org/
- https://serverfault.com/questions/273847/what-does-warning-untrusted-x11-forwarding-setup-failed-xauth-key-data-not-ge
- https://serverfault.com/questions/422908/how-can-i-prevent-the-warning-no-xauth-data-using-fake-authentication-data-for
