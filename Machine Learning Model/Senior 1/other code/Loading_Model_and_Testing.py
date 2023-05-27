# -*- coding: utf-8 -*-
"""
Created on Fri Dec  9 19:55:39 2022

@author: Ayah Abdel-Ghani
"""

import matplotlib.pyplot as plt
import os
import pandas as pd
from scipy.io import wavfile
from scipy import signal
import numpy as np
import librosa
import librosa.display
import wave
import random as rn
import tensorflow as tf
from keras.utils import to_categorical
import seaborn as sns
import json
from sklearn.utils import shuffle
from tensorflow.keras.models import load_model
from sklearn.model_selection import train_test_split
import time
from sklearn.metrics import f1_score, roc_auc_score, precision_score, recall_score, balanced_accuracy_score, \
    classification_report
from sklearn.metrics import confusion_matrix
import seaborn as sn
from sklearn.metrics import make_scorer
from tensorflow.keras import models, layers

def my_precision(y_true, y_pred):
    return precision_score(y_true, y_pred, average='macro')


def my_recall(y_true, y_pred):
    return recall_score(y_true, y_pred, average='macro')


def my_f1(y_true, y_pred):
    return f1_score(y_true, y_pred, average="macro")


def my_classification_report(y_true, y_pred):
    return classification_report(y_true, y_pred)

model = load_model('MFCC_from_WAV_CNN_Model_16.hdf5')

label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Testing_Unseen_Data\\JSONs\\"
wav_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Testing_Unseen_Data\\WAVs\\"

wav_files = [pos_json for pos_json in os.listdir(wav_path) if pos_json.endswith('.wav')]

wav_files = sorted(os.listdir(wav_path), key=lambda x: int(os.path.splitext(x)[0]))

json_files = [pos_json for pos_json in os.listdir(label_path) if pos_json.endswith('.json')]

json_files = sorted(os.listdir(label_path), key=lambda x: int(os.path.splitext(x)[0]))


covid_status = []

for j_file in json_files:
    with open(label_path + j_file, "r") as file:
        try:
            file_data = json.load(file, strict=False)
            file_name = os.path.splitext(j_file)[0]
            status = file_data['status']
            if status == "healthy":
                # file.seek(0)
                file.close()
                covid_status.append(0)
            elif status == "symptomatic":
                # file.seek(0)
                file.close()
                covid_status.append(1)
            elif status == "COVID-19":
                # file.seek(0)
                file.close()
                covid_status.append(2)
        except json.JSONDecodeError as error:
            print("Empty response " + file_name)
            print(status)
            print(error)

covid_status = np.asarray(covid_status)  


MFCCs = []
pad2d = lambda a, i: a[:, 0: i] if a.shape[1] > i else np.hstack((a, np.zeros((a.shape[0],i - a.shape[1]))))

for i in range(len(wav_files)):
    wav, sr = librosa.load(os.path.join(wav_path , wav_files[i]))
    mfcc = librosa.feature.mfcc(wav)
    padded_mfcc = pad2d(mfcc,40)
    MFCCs.append(padded_mfcc)



MFCCs = np.array(MFCCs)


METRICS = [
    'accuracy',
    tf.keras.metrics.Precision(name='precision'),
    tf.keras.metrics.Recall(name='recall'),
]

test_y = to_categorical(np.array(covid_status))

test_X_ex = np.expand_dims(MFCCs, -1)

covPredict = model.predict(test_X_ex)
y_p = np.argmax(covPredict, axis=1)
covPredict=covPredict.astype(int)
y_t = np.argmax(test_y, axis=1)

print("Precision : ", my_precision(y_t, y_p))
print("Recall : ", my_recall(y_t, y_p))
print("F1 : ", my_f1(y_t, y_p))
print("ReportL ", my_classification_report(y_t, y_p))


# Plot confusion matrix
confusion_mtx = tf.math.confusion_matrix(y_t, y_p) 
plt.figure(figsize=(5, 5))
sns.heatmap(confusion_mtx, 
            annot=True, fmt='g', cmap='Greens')
plt.xlabel('Prediction')
plt.ylabel('Label')
plt.show()
