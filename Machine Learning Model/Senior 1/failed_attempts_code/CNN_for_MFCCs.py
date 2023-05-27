# -*- coding: utf-8 -*-
"""
Created on Thu Dec  8 11:55:08 2022

@author: Ayah Abdel-Ghani
"""

import IPython.display as ipd
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import librosa
import cv2
import json
from tqdm import tqdm
from sklearn.preprocessing import StandardScaler
from keras.models import Sequential

from keras.layers import Dense, Dropout
# , Activation

from keras.optimizers import Adam
from sklearn.metrics import f1_score, roc_auc_score, precision_score, recall_score, balanced_accuracy_score, \
    classification_report
import csv
from sklearn.utils import shuffle
from tensorflow.keras.models import load_model
from sklearn.model_selection import train_test_split
import time
from sklearn.metrics import confusion_matrix
from tensorflow.keras.layers import Input
import tensorflow as tf
from sklearn.metrics import make_scorer
from tensorflow.keras.callbacks import ModelCheckpoint
import seaborn as sn

def my_precision(y_true, y_pred):
    return precision_score(y_true, y_pred, average='micro')


def my_recall(y_true, y_pred):
    return recall_score(y_true, y_pred, average='micro')


def my_f1(y_true, y_pred):
    return f1_score(y_true, y_pred, average="micro")


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
    print(histories)
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

    
# reading the MFCCs
path_to_text = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_MFCC_features\\"
text_files = [pos_json for pos_json in os.listdir(path_to_text) if pos_json.endswith('.txt')]

text_files = sorted(os.listdir(path_to_text), key=lambda x: int(os.path.splitext(x)[0]))

MFCCs = np.empty(shape=(len(text_files), 13, 450))
3360, 13, 450
print(MFCCs)

# len(text_files)
for n in range(len(text_files)):
    text = []
    with open(path_to_text+text_files[n], 'r') as csvfile:
        matrixreader = csv.reader(csvfile, delimiter=' ')
        for row in matrixreader:
            if(row != []):
                text.append(row)
    text = np.array(text)
    print(text.shape)
    for i in range(len(text)):
        for m in range(len(text[i])):
            MFCCs[n][i][m] = text[i][m]
    # MFCCs.append(text)

print(MFCCs.shape)

# MFCC = np.empty((arow, acol))

# for i in range(len(MFCCs)):
#     np.append(MFCC,MFCCs[i])
    
# print(MFCC.shape)

# reading the json files
path_to_json = 'C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_JSON_features\\'
json_files = [pos_json for pos_json in os.listdir(path_to_json) if pos_json.endswith('.json')]

json_files = sorted(os.listdir(path_to_json), key=lambda x: int(os.path.splitext(x)[0]))


covid_status = []

for j_file in json_files:
    with open(path_to_json + j_file, "r") as file:
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


# print("Dataset count: ", len(MFCCs), " Shape: ", MFCCs.shape)
# print("Labels count: ", len(covid_status), " Shape: ", covid_status.shape)

# tran = StandardScaler()
# fit_MFCCs = tran.fit_transform(MFCCs)

np.random.seed(75)

MFCCs, covid_status = shuffle(MFCCs, covid_status, random_state=75)
(trainX, testX, trainY, testY) = train_test_split(MFCCs, covid_status, test_size=0.2, shuffle=True)

# print("Train set size : ", len(trainX), " shape: ", trainX.shape)
# print("Test set size : ", len(testX), " shape: ", testX.shape)

# print(trainX[0])

original_trainY = trainY
original_testY = testY
trainY = tf.keras.utils.to_categorical(trainY)
testY = tf.keras.utils.to_categorical(testY)

scoring = {'accuracy': 'accuracy',
            'precision': make_scorer(my_precision),
            'recall': make_scorer(my_recall),
            'f1': make_scorer(my_f1)}

histories = []

METRICS = [
    tf.keras.metrics.Accuracy(name='accuracy'),
    tf.keras.metrics.Precision(name='precision'),
    tf.keras.metrics.Recall(name='recall'),
]



filepath = 'Matlab_cropped_NoFolds_RMSprop_Optim_point2_lastD_001' + '.hdf5'

# checkpoint = ModelCheckpoint(filepath, monitor='val_accuracy', verbose=1, save_best_only=True, mode='max')
# Model architecture
print('------------------------------------------------------------------------')
# print(f'Training for fold {fold_no} ...')

print('Training for Train Test without Fold ...')


epochs = 30
batch_size = 64
# learning_rate = 0.001

input_shape = (26,)

model = Sequential()

model.add(Dense(256, input_shape=(13,450), activation = 'relu'))

model.add(Dense(64, activation = 'relu'))
model.add(Dropout(0.6))

model.add(Dense(32, activation = 'relu'))
model.add(Dropout(0.5))

model.add(Dense(10, activation = 'softmax'))

model.compile(loss='categorical_crossentropy', metrics=METRICS, optimizer='adam')

# model = Model(inputs=inputs, outputs=x)



# model.compile(optimizer=optimizer, loss="categorical_crossentropy", metrics=METRICS)
#

# print("Train Data Shape for Training: ")
# print(trainX.shape)
# print("Train Data Labels Shape for Training: ")
# print(trainY.shape)

# print("Test Data Shape for Testing: ")
# print(testX.shape)
# print("Test Data Labels Shape for Testing: ")
# print(testY.shape)

start = time.time()
history = model.fit(trainX, trainY, batch_size=batch_size, epochs=epochs,
                    validation_data=(testX, testY))
end = time.time()

# , callbacks=[checkpoint]

print("Training time : ", (end - start))
histories.append(history)

scores = model.evaluate(testX, testY, verbose=0)

covPredict = model.predict(testX)
predictions = []
for n in range(len(covPredict)):
    predictions.append(np.argmax(covPredict[n]))

covPredict = predictions

for i in covPredict:
    print(i, end=", ")

print("")

# real_stat = testY

print("Accuracy : ", scores[1])
print("Precision : ", my_precision(original_testY, covPredict))
print("Recall : ", my_recall(original_testY, covPredict))
print("F1 : ", my_f1(original_testY, covPredict))
print("ReportL ", my_classification_report(original_testY, covPredict))

# Plot accuracy curves
plotCurves('CNN-LSTM train and validation accuracy curves', 'Accuracy', 'Epoch', 'accuracy', histories)

# Plot loss curves
plotCurves('CNN-LSTM train and validation loss curves', 'Loss', 'Epoch', 'loss', histories)

# Plot Precision curves
plotCurves('CNN-LSTM train and validation precision curves', 'Precision', 'Epoch', 'precision', histories)

# Plot confusion matrix
plotConfusionMatrix(original_testY, covPredict)