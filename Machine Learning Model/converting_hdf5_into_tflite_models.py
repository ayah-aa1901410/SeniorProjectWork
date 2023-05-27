# -*- coding: utf-8 -*-
"""
Created on Mon Feb 27 20:39:07 2023

@author: Ayah Abdel-Ghani
"""

import tensorflow as tf
from tensorflow.keras.models import load_model

# # Convert the model
# model = load_model("C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\ML_Nav_app_version_01\\assets\\Augmented_02_2_Classes_Model_Last_trial.hdf5")
# converter = tf.lite.TFLiteConverter.from_keras_model(model) # path to the SavedModel directory
# tflite_model = converter.convert()

# # Save the model.
# with open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\ML_Nav_app_version_01\\assets\\Model_02_89.tflite', 'wb') as f:
#   f.write(tflite_model)

from tensorflow import lite

model = load_model("C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\ML_Nav_app_version_01\\assets\\Augmented_2_Classes_Model_1.hdf5")
converter = lite.TFLiteConverter.from_keras_model(model)

converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.experimental_new_converter=True
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS,
tf.lite.OpsSet.SELECT_TF_OPS]

tfmodel = converter.convert()
open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\ML_Nav_app_version_01\\assets\\Model_01_92.tflite', 'wb').write(tfmodel)
