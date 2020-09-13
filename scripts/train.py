import os
from azureml.core import Run

comment="""Output from an ML run
---------------------

  Anything saved in the outputs/ directory is saved and available after the run.

  azureml.core.Run.get_context().log(...) can be used for logging.

  To do ML training, choose an environment that includes your preferred framework. The environment will
  then include Python, and the framework you choose. Environments can be further customised for other packages
  you may want. 

  See https://docs.microsoft.com/en-us/azure/machine-learning/resource-curated-environments for curated environments.
  """
azureMLRun = Run.get_context()
azureMLRun.log("Log","Successfully ran script and logged to azureml.core.Run.get_context().log(...)")
azureMLRun.log("More log", "use azureml.core.Run.get_context().log("string", item):")
azureMLRun.log("And more","Files saved to the outputs/ directory stays available after the run.")
azureMLRun.log("And finally",comment)

output=open('outputs/example-output.txt', 'w')
output.write(comment)
output.close()
