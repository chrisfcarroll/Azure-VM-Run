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

print("Where does print output go?")
print(comment)

azureMLRun = Run.get_context()
azureMLRun.log("How To Log Metrics","This was the first logged message")
azureMLRun.log("How To Log Metrics", "use azureml.core.Run.get_context().log('MetricName', value)")
azureMLRun.log("How To Log Metrics","Files saved to the outputs/ directory stay available after the run.")


if not os.path.exists('outputs'):
  azureMLRun.log("How To Output","output directory outputs/ did not exist. Creating it in " + os.getcwd() )

os.makedirs('outputs', exist_ok=True)
output=open('outputs/example-output.txt', 'w')
output.write(comment)
output.close()

