# Create Azure Machine Learning Resources for Training

```
Create-AzMLResources-And-Submit-ForTraining.ps1 
    [[-resourceGroupName] <String> [-location <StringLocationName>]] 
    [[-workspaceName] <String>] 
    [[-computeTargetName] <String> [-computeTargetSize <StringvmSize>]] 
    [[-experimentName] <String>] 
    [-datasetName <String> | -datasetDefinitionFile <path> | -datasetId <StringGuid>]
    [-environmentFor <String> | -environmentName <String>] 
    [-attachFolder [ Yes | No | Ask ] ] 
    [-script <path>] 
    [-submit] 
    [-noConfirm]   
    [-help] 
    [<CommonParameters>]
```

This repository is primarily about the script file `Create-AzMLResources-And-Submit-ForTraining.ps1`  which will help you to perform one or all of:
  -create the nested sequence of Azure resources needed to run a script on an Azure ML computetarget 
  -create a runconfig file for the script and the resources
  -submit the run

- The script is based on the steps at https://docs.microsoft.com/en-us/azure/machine-learning/tutorial-train-deploy-model-cli
- You can use the script to the very end, or just use parts of it.
- *Required:* You must already have an Azure Subscription with permissions to create 
resources. If you don't have one, you can get a new one for free in about 
10 minutes at https://azure.com

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
Create-AzMLResources-And-Submit-ForTraining.ps1 ml1 ml1 ml1 -location uksouth
```
Creates:
  -a resourceGroup named ml1 in Azure location uksouth,
  -a workspace named ml1 in that resourceGroup,
  -a computetarget ml1 of default size (nc6) in the workspace
and stops
  
```
Create-AzMLResources-And-Submit-ForTraining.ps1 ml1 ml1 ml1 ml1
  -datasetName mnist-dataset 
  -environmentFor TensorFlow 
  -script ./scripts/train.py
  -attachFolder Yes
```
Will do these steps:
 - Ensure or creates:
     - a resourceGroup, a workspace, a computetarget and an experiment, all called ml1
 - Ensure a dataset named mnist-dataset already exists in your workspace
 - Pick the alphabetically last environment with name matching TensorFlow
 - Ensure the script ./scripts/train.py
 - Attach your current folder to the workspace
 - Generate a runconfig file called ml1.runconfig
 - Show you the command line to submit the run
If you add the -submit flag it will also start the run

####Show me the GUI?

The GUI way to do this is at https://ml.azure.com, and it can take you through
similar initial steps as this script. 
You can also use the GUI as a dashboard, to see that what the script does
appears as expected in your azure account.

## Azure GPU options

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
