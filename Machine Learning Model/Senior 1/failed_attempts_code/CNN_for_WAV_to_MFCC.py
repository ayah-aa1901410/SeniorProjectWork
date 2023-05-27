# -*- coding: utf-8 -*-
"""
Created on Fri Dec  9 12:26:53 2022

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
    return precision_score(y_true, y_pred, average='macro')


def my_recall(y_true, y_pred):
    return recall_score(y_true, y_pred, average='macro')


def my_f1(y_true, y_pred):
    return f1_score(y_true, y_pred, average="macro")


def my_classification_report(y_true, y_pred):
    return classification_report(y_true, y_pred)


def progressBar(iterable, prefix='', suffix='', decimals=1, length=100, fill='█', printEnd="\r"):
    total = len(iterable)

    # Progress Bar Printing Function
    def printProgressBar(iteration):
        percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
        filledLength = int(length * iteration // total)
        bar = fill * filledLength + '-' * (length - filledLength)
        print(f'\r{prefix} |{bar}| {percent}% {suffix}', end=printEnd)

    printProgressBar(0)
    for i, item in enumerate(iterable):
        yield item
        printProgressBar(i + 1)
    print()


def plotCurves(title, x, y, curve, histories):
    plt.figure(figsize=(14, 8))
    train_all = []
    train_avg = []
    for entry in histories:
        plt.plot(entry.history[curve], ls='dashed', alpha=0.2, color='tomato')
        train_all.append(entry.history[curve])
    train_all = np.array(train_all)
    train_avg = np.average(train_all, axis=0)
    plt.plot(train_avg, ls='-', lw=2, label='Average train ' + curve, color='tomato')
    val_all = []
    val_avg = []
    for entry in histories:
        plt.plot(entry.history['val_' + curve], ls='dashed', alpha=0.2, color='darkcyan')
        val_all.append(entry.history['val_' + curve])
    val_all = np.array(val_all)
    val_avg = np.average(val_all, axis=0)
    plt.plot(val_avg, ls='-', lw=2, label='Average validation ' + curve, color='darkcyan')
    plt.title(title)
    plt.ylabel(x)
    plt.xlabel(y)
    plt.legend(loc='best')
    plt.grid()
    plt.show()
    
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
    ax.yaxis.set_ticklabels(['Negative', 'Symptomatic', 'Positive'])
    plt.show()


label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_JSON_mfccfromwav\\"
wav_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_WAV_mfccfromwav\\"

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

# scoring = {'accuracy': 'accuracy',
#             'precision': make_scorer(my_precision),
#             'recall': make_scorer(my_recall),
#             'f1': make_scorer(my_f1)}

histories = []

METRICS = [
    'accuracy',
    tf.keras.metrics.Precision(name='precision'),
    tf.keras.metrics.Recall(name='recall'),
]


print('Training for Train Test ...')

lr = 0.0001

optimizer = tf.keras.optimizers.Adam(learning_rate= lr)

ip = tf.keras.layers.Input(shape=train_X_ex[0].shape)


# CNN

# m = tf.keras.layers.Conv2D(128, kernel_size=(3, 3), activation='relu')(ip)
# m = tf.keras.layers.MaxPooling2D((3,3))(m)
# m = tf.keras.layers.Conv2D(256, kernel_size=(3, 3), activation='relu')(m)
# m = tf.keras.layers.MaxPooling2D((3,3))(m)
# m = tf.keras.layers.Dropout(0.7)(m)
m = tf.keras.layers.Dense(128, activation='relu')(ip)
m= tf.keras.layers.BatchNormalization(momentum=0.9)(m)
m = tf.keras.layers.Flatten()(m)
m = tf.keras.layers.Dense(256, activation='relu')(m)
m = tf.keras.layers.Dense(128, activation='relu')(m)
# m = tf.keras.layers.MaxPooling2D((3,3))(m)
m = tf.keras.layers.Dropout(0.7)(m)
m = tf.keras.layers.Dense(60, activation='relu')(m)
m = tf.keras.layers.Dense(30, activation='relu')(m)
op = tf.keras.layers.Dense(3, activation='softmax')(m)

model = tf.keras.Model(inputs=ip, outputs=op)



filepath = 'MFCC_from_WAV_CNN_Model_16' + '.hdf5'
# Create a callback that saves the model's weights
cp_callback = tf.keras.callbacks.ModelCheckpoint(filepath=filepath, save_best_only=True, mode='max', monitor='val_accuracy', verbose=1)

# 

model.compile(loss='categorical_crossentropy',
              optimizer=optimizer,
              metrics='accuracy')

start = time.time()
history = model.fit(train_X_ex,
          train_y,
          epochs=500,
          batch_size=32,
          validation_data=(test_X_ex, test_y),
          callbacks=[cp_callback])
end = time.time()


# scores = model.evaluate(test_X_ex, test_y, verbose=0)

covPredict = model.predict(test_X_ex)
y_p = np.argmax(covPredict, axis=1)
covPredict=covPredict.astype(int)
y_t = np.argmax(test_y, axis=1)

# print("Accuracy : ", scores[1])
print("Precision : ", my_precision(y_t, y_p))
print("Recall : ", my_recall(y_t, y_p))
print("F1 : ", my_f1(y_t, y_p))
print("ReportL ", my_classification_report(y_t, y_p))


# # Plot accuracy curves
# plotCurves('CNN-LSTM train and validation accuracy curves', 'Accuracy', 'Epoch', 'accuracy', histories)

# # Plot loss curves
# plotCurves('CNN-LSTM train and validation loss curves', 'Loss', 'Epoch', 'loss', histories)

# # Plot Precision curves
# plotCurves('CNN-LSTM train and validation precision curves', 'Precision', 'Epoch', 'precision', histories)

# plot curves

plt.plot(history.history['accuracy'], label='Train Accuracy')
plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
# plt.plot(history.history['precision'], label='Train Precision')
# plt.plot(history.history['val_precision'], label='Validation Precision')
# plt.plot(history.history['recall'], label='Train Recall')
# plt.plot(history.history['val_recall'], label='Validation Recall')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend()

# Plot confusion matrix
confusion_mtx = tf.math.confusion_matrix(y_t, y_p) 
plt.figure(figsize=(5, 5))
sns.heatmap(confusion_mtx, 
            annot=True, fmt='g', cmap='Greens')
plt.xlabel('Prediction')
plt.ylabel('Label')
plt.show()








