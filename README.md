# AzureMLSetup

```
azure-ml-setup.ps1 
      [[-resourceGroupName] <string> [[-location] <string>]]
      [[-workspaceName] <string>] 
      [[-computeTargetName] <string> [[-computeTargetSize] <string>]]
      [[-experimentName] <string>] 
      [[-datasetDefinitionFile] <string>]
```

This repository is primarily about the script file `azure-ml-setup.ps1`  which will create the nested sequence of Azure resources needed to run a script on an Azure ML computetarget. 

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
      ├── Dataset
      ├── Computetarget (with a vmSize)
      └── Experiment
          └── runconfig (which references the dataset and the computetarget)

As you can see, the Workspace is the primary Container. 
- Keeping an empty WorkSpace alive costs about $1 per day.
- To create and destroy a workspace each time you start work typically takes a couple of minutes, and that is the first part of what this script automates.

####Show me the GUI?

The GUI way to do this is at https://ml.azure.com, which will take you through
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
