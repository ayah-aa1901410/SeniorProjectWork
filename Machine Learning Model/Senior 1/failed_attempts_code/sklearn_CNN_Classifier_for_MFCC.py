# -*- coding: utf-8 -*-
"""
Created on Fri Dec  9 22:07:39 2022

@author: Ayah Abdel-Ghani
"""

from sklearn.neural_network import MLPClassifier
import numpy as np
import pickle
from sklearn.metrics import average_precision_score, accuracy_score
from sklearn.model_selection import GridSearchCV
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

def my_precision(y_true, y_pred):
    return precision_score(y_true, y_pred, average='macro')


def my_recall(y_true, y_pred):
    return recall_score(y_true, y_pred, average='macro')


def my_f1(y_true, y_pred):
    return f1_score(y_true, y_pred, average="macro")


def my_classification_report(y_true, y_pred):
    return classification_report(y_true, y_pred)

label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_JSON_mfccfromwav\\"
wav_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_WAV_mfccfromwav\\"

# label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Number_Names_Separated_WAV_Jsons\\Wavs_Jsons_number_names\\"
# wav_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Number_Names_Separated_WAV_Jsons\\Wavs_Jsons_number_names\\"

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

np.random.seed(75)

MFCCs, covid_status = shuffle(MFCCs, covid_status, random_state=75)
(trainX, testX, trainY, testY) = train_test_split(MFCCs, covid_status, test_size=0.2, shuffle=True)
     
train_y = to_categorical(np.array(trainY))   
test_y = to_categorical(np.array(testY))

train_X_ex = np.expand_dims(trainX, -1)
test_X_ex = np.expand_dims(testX, -1)

METRICS = [
    'accuracy',
    tf.keras.metrics.Precision(name='precision'),
    tf.keras.metrics.Recall(name='recall'),
]

print('Training for Train Test ...')

nsamples, nx, ny, nz = train_X_ex.shape
train_X_ex = train_X_ex.reshape((nsamples,nx*ny*nz))

nsamples, nx, ny, nz = test_X_ex.shape
test_X_ex = test_X_ex.reshape((nsamples,nx*ny*nz))

model = MLPClassifier(hidden_layer_sizes=(100,200,200,100),  max_iter=500, activation='relu', solver='adam', verbose=1, )
# ,  min_samples_split=2

# model = LogisticRegression(C=100, fit_intercept=True, 
# max_iter=500, solver='newton-cg', penalty='l2', multi_class='ovr')

model.fit(train_X_ex, trainY)

with open('MFCC_from_WAV_MLPClassifier_Model_04.hdf5','wb') as f:
        pickle.dump(model, f)
        
# score = model.score(test_X_ex, testY)
# print(score)

pred_spectro = model.predict(test_X_ex)
# y_p = np.argmax(pred_spectro, axis=1)
pred_spectro=pred_spectro.astype(int)
# y_t = np.argmax(test_y, axis=1)

# print("Accuracy : ", scores[1])
print("Precision : ", my_precision(testY, pred_spectro))
print("Recall : ", my_recall(testY, pred_spectro))
print("F1 : ", my_f1(testY, pred_spectro))
print("ReportL ", my_classification_report(testY, pred_spectro))

# plt.plot(history.history['accuracy'], label='Train Accuracy')
# plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
# plt.xlabel('Epochs')
# plt.ylabel('Accuracy')
# plt.legend()

# Plot confusion matrix
confusion_mtx = tf.math.confusion_matrix(testY, pred_spectro) 
plt.figure(figsize=(5, 5))
sns.heatmap(confusion_mtx, 
            annot=True, fmt='g', cmap='Greens')
plt.xlabel('Prediction')
plt.ylabel('Label')
plt.show()
