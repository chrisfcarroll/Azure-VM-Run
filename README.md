# `az ml` Quickstart
## Create Azure machine learning resources and submit a run, from scratch in 10 minutes

#### *Required:*
1. An [Azure Subscription](https://azure.com) with access to create resources
2. The script is written in [PowerShell](https://github.com/PowerShell/PowerShell)
3. Step 0 is to [install the az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Option 1. Using Azure's managed infrastructure for ML training

_NB to copy and paste into a non-powershell shell, replace the backtick line-continuation marks with backslash before pasting_
```
./Create-AzMLResources-And-Submit.ps1 ml1 ml1 ml1 ml1 -location uksouth `
        -environmentFor PyTorch `
        -submit `
        -NoConfirm
```
- Will create a `Resource Group` with a `Workspace` with a `computetarget` and an `experiment` all named ml1
- Will give you an example PyTorch script and an example dataset (namely mnist) to train a model
- Will submit the run and stay attached in order to stream the logs to your console
You can see progress and output at https://ml.azure.com or with `az ml run list`

#### Cleanup
Keeping a workspace will cost you about $1 per day. Delete the whole resource group or just the workspace with:
```
az group delete --name ml1
az workspace delete --name ml1
```

#### More Details including TensorFlow etc
```
./Create-AzMLResources-And-Submit.ps1 -?
```


## Option 2. Using an Azure Data Science Virtual Machine image

_NB to copy and paste into a non-powershell shell, replace the backtick line-continuation marks with backslash before pasting_
```
./Create-AzVM-ForDataSciencePython.ps1 ml1 ml1 -location uksouth `
        -gitRepository https://github.com/chrisfcarroll/TensorFlow-2.x-Tutorials `
        -copyLocalFolder . `
        -commandToRun "python TensorFlow-2.x-Tutorials/11-AE/ex11AutoEncoderMnist.py"  
```
- Will create a `Resource Group` and a `Virtual Machine` both named ml1
- will accept the license for the Data Science Virtual Machine image
- Will clone the git repo specified
- Will copy the local folder specified to the VM
- Will run the given command
_NB At the point of connecting to a new VM, `ssh` will ask you if you are ok to connect to the new host_

#### Cleanup
Keeping a small VM running will cost you several cents per day. Delete the whole resource group or just the VM with:
```
az group delete --name ml1
az vm delete --name ml1
```

#### More Details:
```
./Create-AzVM-ForDataSciencePython.ps1 -?
```

#In More Detail

## 1. Using Azure's managed infrastructure for ML training

- The script is based on the steps at https://docs.microsoft.com/en-us/azure/machine-learning/tutorial-train-deploy-model-cli
- You can use the script to the very end, or just use parts of it.
- The script defaults to computetarget size = NC6 which is the cheapset VM size with a GPU

#### Resources created

What is needed to create, use, & tear down cloud-based ML resources?

[Azure Subscription]
  └── ResourceGroup (at a location)
      └── WorkSpace
          ├── Computetarget (with a vmSize which may include GPU)
          ├── Dataset(s) (optional)
          └── Experiment
              └── runconfig 
                  (which references the computetarget, the optional dataset, 
                   the experiment and a script)

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

####Show me the GUI?

The GUI way to do this is at https://ml.azure.com, and it can take you through
similar initial steps as this script. 
You can also use the GUI as a dashboard, to see that what the script does
appears as expected in your azure account, and to see experiment results


## 2. Using an Azure Data Science Virtual Machine' image for ML training or work

- Microsoft have published several “Data Science Virtual Machine” images. The script uses the one recommended for CUDA which is:
`microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:20.01.09`
- The script defaults to VM size = NC6 which is the cheapset VM size with a GPU
- Advantages of a VM over a computetarget: 
  - Interactive not batch. You can SSH to the VM or connect from X-windows, so it's a desktop experience
  - Often (in my experience) faster startup and no waiting in a queue for resources
- All the parameters `-gitRepository  -copyLocalFolder -commandToRun` will run with current directory as the Home directory, so copied or git-cloned folders can be referenced with a simple relative path, as in the example above.


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

### N series GPU enabled virtual machines

https://azure.microsoft.com/en-gb/pricing/details/virtual-machines/series/

The N-series is a family of Azure Virtual Machines with GPU capabilities. GPUs are ideal for compute and graphics-intensive workloads, helping customers to fuel innovation through scenarios such as high-end remote visualisation, deep learning and predictive analytics.

The N-series has three different offerings aimed at specific workloads:

    The NC-series is focused on high-performance computing and machine learning workloads. The latest version – NCsv3 – features NVIDIA’s Tesla V100 GPU.
    The NDs-series is focused on training and inference scenarios for deep learning. It uses the NVIDIA Tesla P40 GPUs. The latest version – NDv2 – features the NVIDIA Tesla V100 GPUs.
    The NV-series enables powerful remote visualisation workloads and other graphics-intensive applications backed by the NVIDIA Tesla M60 GPU.

NCsv3, NCsv2, NC and NDs VMs offer optional InfiniBand interconnect to enable scale-up performance.

### GPU optimized virtual machine sizes

https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-gpu?toc=/azure/virtual-machines/linux/toc.json&bc=/azure/virtual-machines/linux/breadcrumb/toc.json
