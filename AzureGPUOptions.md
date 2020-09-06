# Azure GPU options

## TL;DR

Use a N-series VM for the NVidia Tesla GPUs. Note that the oldest hardware - NC series - now has 50% off promo options.
Choose from 
- $0.60 per hour for NC6Promo - Tesla K80 (2015 design, 2496 cores @ 560MHz-875MHz 24GB GDDR5)
- $1.20-$2.50 per hour for NC12 or NC24 Promo - 2 or 4 x Tesla K80 (2015 design, 2496 cores @ 560MHz-875MHz 24GB GDDR5)
- $7-15 per hour for NC12v3 - NC24v3 - 2-4 x Tesla V100 (640TensorCores,5120Cuda Cores, 32-64GB HBM2 memory)

## N series GPU enabled virtual machines

https://azure.microsoft.com/en-gb/pricing/details/virtual-machines/series/

The N-series is a family of Azure Virtual Machines with GPU capabilities. GPUs are ideal for compute and graphics-intensive workloads, helping customers to fuel innovation through scenarios such as high-end remote visualisation, deep learning and predictive analytics.

The N-series has three different offerings aimed at specific workloads:

    The NC-series is focused on high-performance computing and machine learning workloads. The latest version – NCsv3 – features NVIDIA’s Tesla V100 GPU.
    The NDs-series is focused on training and inference scenarios for deep learning. It uses the NVIDIA Tesla P40 GPUs. The latest version – NDv2 – features the NVIDIA Tesla V100 GPUs.
    The NV-series enables powerful remote visualisation workloads and other graphics-intensive applications backed by the NVIDIA Tesla M60 GPU.

NCsv3, NCsv2, NC and NDs VMs offer optional InfiniBand interconnect to enable scale-up performance.

# GPU optimized virtual machine sizes

https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-gpu?toc=/azure/virtual-machines/linux/toc.json&bc=/azure/virtual-machines/linux/breadcrumb/toc.json

NC-