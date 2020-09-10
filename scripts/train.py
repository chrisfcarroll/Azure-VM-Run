import numpy as np
from numpy import ndarray
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers, metrics, datasets
from tensorflow.data import Dataset
import os
from azureml.core import Run

azureMLRun = Run.get_context()
os.environ['TF_CPP_MIN_LOG_LEVEL']='2'
"train.py"
azureMLRun.log("train.py", "")

def get_mnist_dataset() -> ((ndarray, ndarray), (ndarray, ndarray)):
    xtrain:ndarray;ytrain:ndarray;xval:ndarray;yval:ndarray

    def mnist_to_float32int32(x,y):
        return tf.cast(x,tf.float32)/255.0, tf.cast(y,tf.int32)

    (xtrain, ytrain,), (xval, yval) = datasets.mnist.load_data()
    print('(x,y) shapes: ', xtrain.shape, ytrain.shape)
    ytrain=tf.one_hot(ytrain, depth=10)
    yval=tf.one_hot(yval, depth=10)
    ds_train=tf.data.Dataset.from_tensor_slices((xtrain,ytrain))\
        .map(mnist_to_float32int32).shuffle(xtrain.shape[0]).batch(100)

    ds_val=tf.data.Dataset.from_tensor_slices((xval,yval))\
        .map(mnist_to_float32int32).shuffle(xval.shape[0]).batch(100)

    return ds_train,ds_val


train_ds, val_ds=get_mnist_dataset()

model=keras.Sequential([
    layers.Reshape(target_shape=(28*28,), input_shape=(28,28)),
    layers.Dense(200,activation='relu'),
    layers.Dense(200,activation='relu'),
    layers.Dense(200,activation='relu'),
    layers.Dense(10)
    ])

model.compile(
    optimizer=optimizers.Adam(),
    loss=tf.losses.CategoricalCrossentropy(from_logits=True),
    metrics=['accuracy'])

model.fit(train_ds.repeat(), epochs=3, steps_per_epoch=500,
          validation_data=val_ds.repeat(),
          validation_steps=2)

keras.models.save_model(model,'outputs/mnist-dense4layer-after30x500steps')

(v_loss,v_accuracy)=model.evaluate(val_ds)
azureMLRun.log('test (loss,accuracy):', (v_loss,v_accuracy))
azureMLRun.log('test loss:', v_loss)
azureMLRun.log('test accuracy:', v_accuracy)


