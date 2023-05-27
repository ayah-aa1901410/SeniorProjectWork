# -*- coding: utf-8 -*-
"""
Created on Sat Dec 10 11:35:40 2022

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
from tensorflow.keras.layers import Conv2D
from tensorflow.keras.layers import AveragePooling2D
from tensorflow.keras.layers import Reshape
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Dropout
from tensorflow.keras.layers import Input
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Activation
from tensorflow.keras.layers import BatchNormalization
from tensorflow.keras.layers import LSTM
from tensorflow.keras.layers import Flatten
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import GridSearchCV
from sklearn.pipeline import make_pipeline
from sklearn.linear_model import LogisticRegression
from scipy.stats import randint
# %matplotlib inline

def my_precision(y_true, y_pred):
    return precision_score(y_true, y_pred)


def my_recall(y_true, y_pred):
    return recall_score(y_true, y_pred)


def my_f1(y_true, y_pred):
    return f1_score(y_true, y_pred)


def my_classification_report(y_true, y_pred):
    return classification_report(y_true, y_pred)

    
def plotConfusionMatrix(y_true, y_pred):
    conf_matrix = confusion_matrix(y_true, y_pred)
    norm_array = conf_matrix.astype('float') / conf_matrix.sum(axis=1)[:, np.newaxis]
    group_counts = ["{0:0.0f}".format(value) for value in conf_matrix.flatten()]
    group_percentages = ["{0:.2%}".format(value) for value in norm_array.flatten()]
    labels = [f"{v1}\n\n{v2}" for v1, v2 in zip(group_counts,group_percentages)]
    labels = np.asarray(labels).reshape(3, 3)
    df_cm = pd.DataFrame(conf_matrix, range(3), range(3))
    ax = sn.heatmap(df_cm, annot=labels, fmt='', cmap='Greens')
    ax.set_title('CNN model confusion matrix');
    ax.set_xlabel('Predicted Values')
    ax.set_ylabel('Actual Values');
    # Ticket labels - List must be in alphabetical order
    ax.xaxis.set_ticklabels(['Negative', 'Symptomatic', 'Positive'])
    ax.yaxis.set_ticklabels(['Negative', 'Symptomatic', 'Positive'], va="center")
    plt.show()


label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_JSON_frommfcc2classes01\\"
wav_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_WAV_frommfcc2classes01\\"

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
            # elif status == "symptomatic":
            #     # file.seek(0)
            #     file.close()
            #     covid_status.append(1)
            elif status == "COVID-19":
                # file.seek(0)
                file.close()
                covid_status.append(1)
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

train_X_ex = np.expand_dims(trainX, -1)
test_X_ex = np.expand_dims(testX, -1)

# scoring = {'accuracy': 'accuracy',
#             'precision': make_scorer(my_precision),
#             'recall': make_scorer(my_recall),
#             'f1': make_scorer(my_f1)}

histories = []

METRICS = [
    tf.keras.metrics.BinaryAccuracy(name='accuracy'),
    tf.keras.metrics.Precision(name='precision'),
    tf.keras.metrics.Recall(name='recall'),
]


print('Training for Train Test ...')

lr = 0.000001

optimizer = tf.keras.optimizers.Adam(learning_rate= lr)

ip = tf.keras.layers.Input(shape=train_X_ex[0].shape)


# NN
m = tf.keras.layers.Conv2D(128, kernel_size=(4, 4), activation='relu')(ip)
m = tf.keras.layers.MaxPooling2D(pool_size=(4, 4))(m)
m= tf.keras.layers.BatchNormalization()(m)
m = tf.keras.layers.Dropout(0.2)(m)
m = tf.keras.layers.Flatten()(m)
m = tf.keras.layers.Dense(64, activation='relu')(m)
m = tf.keras.layers.Dense(32, activation='relu')(m)
op = tf.keras.layers.Dense(1, activation='sigmoid')(m)

model = tf.keras.Model(inputs=ip, outputs=op)

model.summary()

filepath = 'MFCC_from_WAV_CNN_Model_2_class_02' + '.hdf5'
# Create a callback that saves the model's weights
cp_callback = tf.keras.callbacks.ModelCheckpoint(filepath=filepath, save_best_only=True, mode='max', monitor='val_accuracy', verbose=1)

# 

model.compile(loss='binary_crossentropy',
              optimizer=optimizer,
              metrics=METRICS)

start = time.time()
history = model.fit(train_X_ex,
          trainY,
          epochs=100,
          batch_size=32,
          validation_data=(test_X_ex, testY),
          callbacks=[cp_callback])
end = time.time()


# scores = model.evaluate(test_X_ex, test_y, verbose=0)

covPredict = model.predict(test_X_ex)
# y_p = np.argmax(covPredict, axis=1)
covPredict=covPredict.astype(int)
# y_t = np.argmax(testY, axis=1)

# print("Accuracy : ", scores[1])
print("Precision : ", my_precision(testY, covPredict))
print("Recall : ", my_recall(testY, covPredict))
print("F1 : ", my_f1(testY, covPredict))
print("ReportL ", my_classification_report(testY, covPredict))

# plot curves

plt.plot(history.history['accuracy'], label='Train Accuracy')
plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend()

# Plot confusion matrix
confusion_mtx = tf.math.confusion_matrix(testY, covPredict) 
plt.figure(figsize=(5, 5))
sns.heatmap(confusion_mtx, 
            annot=True, fmt='g', cmap='Greens')
plt.xlabel('Prediction')
plt.ylabel('Label')
plt.show()