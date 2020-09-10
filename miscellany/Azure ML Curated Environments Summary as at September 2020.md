# Azure Machine Learning Curated Environments

https://docs.microsoft.com/en-us/azure/machine-learning/resource-curated-environments

Most recent GPU-enabled Curated Environments for PyTorch & TensorFlow in uksouth in September 2020:
- AzureML-TensorFlow-2.2-GPU
- AzureML-PyTorch-1.6-GPU

## Generate A Full List Of Available Curated Environments In Your Location

```
az ml environment list -w your-workspace-name --output table
```

### Summary Output in September 2020 for a workspace in uksouth

Name                            Version  
------------------------------  ---------
AzureML-AutoML                  35
AzureML-AutoML-DNN              33
AzureML-AutoML-DNN-GPU          23
AzureML-AutoML-DNN-Vision-GPU   14
AzureML-AutoML-GPU              23
AzureML-Chainer-5.1.0-CPU       36
AzureML-Chainer-5.1.0-GPU       37
AzureML-Dask-CPU                22
AzureML-Dask-GPU                20
AzureML-Designer                19
AzureML-Designer-CV             10
AzureML-Designer-CV-Transform   10
AzureML-Designer-IO             18
AzureML-Designer-NLP            14
AzureML-Designer-PyTorch        11
AzureML-Designer-PyTorch-Train  7
AzureML-Designer-R              19
AzureML-Designer-Recommender    20
AzureML-Designer-Score          11
AzureML-Designer-Transform      18
AzureML-Designer-VowpalWabbit   6
AzureML-Hyperdrive-ForecastDNN  35
AzureML-Minimal                 36
AzureML-PySpark-MmlSpark-0.15   32       
AzureML-PyTorch-1.0-CPU         36
AzureML-PyTorch-1.0-GPU         37
AzureML-PyTorch-1.1-CPU         36
AzureML-PyTorch-1.1-GPU         37
AzureML-PyTorch-1.2-CPU         36
AzureML-PyTorch-1.2-GPU         37
AzureML-PyTorch-1.3-CPU         32
AzureML-PyTorch-1.3-GPU         35
AzureML-PyTorch-1.4-CPU         27
AzureML-PyTorch-1.4-GPU         27
AzureML-PyTorch-1.5-CPU         17
AzureML-PyTorch-1.5-GPU         18
AzureML-PyTorch-1.6-CPU         4
AzureML-PyTorch-1.6-GPU         4
AzureML-Scikit-learn-0.20.3     36
AzureML-Sidecar                 11
AzureML-TensorFlow-1.10-CPU     36
AzureML-TensorFlow-1.10-GPU     37
AzureML-TensorFlow-1.12-CPU     35
AzureML-TensorFlow-1.12-GPU     37
AzureML-TensorFlow-1.13-CPU     36
AzureML-TensorFlow-1.13-GPU     37
AzureML-TensorFlow-2.0-CPU      34
AzureML-TensorFlow-2.0-GPU      35
AzureML-TensorFlow-2.1-CPU      11
AzureML-TensorFlow-2.1-GPU      12
AzureML-TensorFlow-2.2-CPU      4
AzureML-TensorFlow-2.2-GPU      4
AzureML-Tutorial                49
AzureML-VowpalWabbit-8.8.0      25


## Full Json Output in September 2020 for a workspace in uksouth

```json
[{
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-Tutorial",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["anaconda", "conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "azureml-widgets==1.13.0", "azureml-pipeline-core==1.13.0", "azureml-pipeline-steps==1.13.0", "azureml-opendatasets==1.13.0", "azureml-automl-core==1.13.0", "azureml-automl-runtime==1.13.0", "azureml-train-automl-client==1.13.0", "azureml-train-automl-runtime==1.13.0", "azureml-train-automl==1.13.0", "azureml-train==1.13.0", "azureml-sdk==1.13.0", "azureml-interpret==1.13.0", "azureml-tensorboard==1.13.0", "azureml-mlflow==1.13.0", "mlflow", "sklearn-pandas"]
      }, "pandas", "numpy", "tqdm", "scikit-learn", "matplotlib"],
      "name": "azureml_f172a1676bf6f975a6add61ba6cffe97"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "49"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.2-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.2", "torchvision==0.4.0", "mkl==2018.0.3", "horovod==0.16.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_1ae348b0cc0a3dad7317f829d63d27a6"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "36"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-1.12-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow==1.12", "horovod==0.15.2"]
      }],
      "name": "azureml_50c461bd0554d7f137b736d2feaf63ed"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "35"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-1.13-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow==1.13.1", "horovod==0.16.1"]
      }],
      "name": "azureml_fae9db279e4c510d3ac9aada17749e28"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "36"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.1-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.1", "torchvision==0.2.1", "mkl==2018.0.3", "horovod==0.16.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_5e9ebfab7f342562070c0fc92d7a497d"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "36"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-1.10-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow==1.10", "horovod==0.15.2"]
      }],
      "name": "azureml_14560d9340eb94729ccfdb2ddadbbdc7"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "36"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.0-cudnn7-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.0-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.0", "torchvision==0.2.1", "mkl==2018.0.3", "horovod==0.16.1"]
      }],
      "name": "azureml_d4e446e909996aae0841a0158da308ef"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "37"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-cuda9.0-cudnn7-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-1.12-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow-gpu==1.12.0", "horovod==0.15.2"]
      }],
      "name": "azureml_b42578487fc49d5fb244d0e4906c08af"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "37"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-cuda10.0-cudnn7-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-1.13-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow-gpu==1.13.1", "horovod==0.16.1"]
      }],
      "name": "azureml_9090b1ac98fc8140d6217232e511f1b5"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "37"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.0-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.0", "torchvision==0.2.1", "mkl==2018.0.3", "horovod==0.16.1"]
      }],
      "name": "azureml_d4e446e909996aae0841a0158da308ef"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "36"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.0-cudnn7-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.2-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.2", "torchvision==0.4.0", "mkl==2018.0.3", "horovod==0.16.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_1ae348b0cc0a3dad7317f829d63d27a6"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "37"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.0-cudnn7-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.1-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.1", "torchvision==0.2.1", "mkl==2018.0.3", "horovod==0.16.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_5e9ebfab7f342562070c0fc92d7a497d"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "37"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-cuda9.0-cudnn7-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-1.10-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow-gpu==1.10.0", "horovod==0.15.2"]
      }],
      "name": "azureml_c2ed226f05be4b3cf5a5e96a338cb494"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "37"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.0-cudnn7-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.3-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.3", "torchvision==0.4.1", "mkl==2018.0.3", "horovod==0.18.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_ed1f8d39c2c36538e1b2726420cdf464"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "35"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-ubuntu18.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-2.0-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow==2.0", "horovod==0.18.1"]
      }],
      "name": "azureml_7ef6e91495441551b6488199477e745d"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "34"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.3-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.3", "torchvision==0.4.1", "mkl==2018.0.3", "horovod==0.18.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_ed1f8d39c2c36538e1b2726420cdf464"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "32"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.0-cudnn7-ubuntu18.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-2.0-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow-gpu==2.0.0", "horovod==0.18.1"]
      }],
      "name": "azureml_c0190c724e655a6a699bb5ba575faf37"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "35"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.1-cudnn7-ubuntu18.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.4-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.4.0", "torchvision==0.5.0", "mkl==2018.0.3", "horovod==0.18.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_35d1a95a1f7ebe4826715fcbef645b34"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "27"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.4-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.4.0", "torchvision==0.5.0", "mkl==2018.0.3", "horovod==0.18.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_35d1a95a1f7ebe4826715fcbef645b34"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "27"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-ubuntu16.04:20200723.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-Designer-Transform",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["defaults"],
      "dependencies": ["python=3.6.8", {
        "pip": ["azureml-designer-datatransform-modules==0.0.57"]
      }],
      "name": "azureml_c820d349ebc29d6ec49cd023540805e0"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "18"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.5-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.5.0", "torchvision==0.5.0", "mkl==2018.0.3", "horovod==0.19.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_6c683310370f5b3223db8247fc090b1c"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "17"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.1-cudnn7-ubuntu18.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.5-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.5.0", "torchvision==0.5.0", "mkl==2018.0.3", "horovod==0.19.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_6c683310370f5b3223db8247fc090b1c"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "18"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-ubuntu16.04:20200723.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-Designer-CV-Transform",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["defaults"],
      "dependencies": ["python=3.6.8", {
        "pip": ["azureml-designer-cv-modules[pytorch]==0.0.14"]
      }],
      "name": "azureml_b9381d40695f24ca92cb00f6a2a53f46"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "10"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-ubuntu16.04:20200723.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-Designer-PyTorch",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["defaults"],
      "dependencies": ["python=3.6.8", {
        "pip": ["azureml-designer-pytorch-modules==0.0.16"]
      }],
      "name": "azureml_c0d8974aa22cdabc8b52b64b65958186"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "11"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.0-cudnn7-ubuntu18.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-2.1-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow-gpu==2.1.0", "horovod==0.19.1"]
      }],
      "name": "azureml_a04989b2ee14b495b52e30bdc349b754"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "12"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-ubuntu18.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-2.1-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow==2.1.0", "horovod==0.19.1"]
      }],
      "name": "azureml_6a576984f3ec6b370747abebabf7fada"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "11"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/intelmpi2018.3-cuda10.0-cudnn7-ubuntu16.04:20200723.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-Designer-PyTorch-Train",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["defaults"],
      "dependencies": ["python=3.6.8", {
        "pip": ["azureml-designer-pytorch-modules==0.0.16"]
      }],
      "name": "azureml_c0d8974aa22cdabc8b52b64b65958186"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "7"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.1-cudnn7-ubuntu18.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-2.2-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow-gpu==2.2.0", "horovod==0.19.1"]
      }],
      "name": "azureml_c58bf35e1b26936aac12c7976488df1f"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "4"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-ubuntu18.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-TensorFlow-2.2-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "tensorflow==2.2.0", "horovod==0.19.1"]
      }],
      "name": "azureml_985c934bbb7325efc7b22de35715082c"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "4"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-ubuntu16.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.6-CPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.6.0", "torchvision==0.5.0", "mkl==2018.0.3", "horovod==0.19.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_1150af86eabb1f11a2084230761433fc"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "4"
}, {
  "databricks": {
    "eggLibraries": [],
    "jarLibraries": [],
    "mavenLibraries": [],
    "pypiLibraries": [],
    "rcranLibraries": []
  },
  "docker": {
    "arguments": [],
    "baseDockerfile": null,
    "baseImage": "mcr.microsoft.com/azureml/openmpi3.1.2-cuda10.1-cudnn7-ubuntu18.04:20200821.v1",
    "baseImageRegistry": {
      "address": null,
      "password": null,
      "registryIdentity": null,
      "username": null
    },
    "enabled": false,
    "platform": {
      "architecture": "amd64",
      "os": "Linux"
    },
    "sharedVolumes": true,
    "shmSize": null
  },
  "environmentVariables": {
    "EXAMPLE_ENV_VAR": "EXAMPLE_VALUE"
  },
  "inferencingStackVersion": null,
  "name": "AzureML-PyTorch-1.6-GPU",
  "python": {
    "baseCondaEnvironment": null,
    "condaDependencies": {
      "channels": ["conda-forge"],
      "dependencies": ["python=3.6.2", {
        "pip": ["azureml-core==1.13.0", "azureml-defaults==1.13.0", "azureml-telemetry==1.13.0", "azureml-train-restclients-hyperdrive==1.13.0", "azureml-train-core==1.13.0", "torch==1.6.0", "torchvision==0.5.0", "mkl==2018.0.3", "horovod==0.19.1", "tensorboard==1.14.0", "future==0.17.1"]
      }],
      "name": "azureml_1150af86eabb1f11a2084230761433fc"
    },
    "condaDependenciesFile": null,
    "interpreterPath": "python",
    "userManagedDependencies": false
  },
  "r": null,
  "spark": {
    "packages": [],
    "precachePackages": true,
    "repositories": []
  },
  "version": "4"
}]
```