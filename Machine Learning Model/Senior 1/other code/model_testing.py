# -*- coding: utf-8 -*-
"""
Created on Thu Dec 22 22:39:18 2022

@author: Ayah Abdel-Ghani
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import gc
import shutil
import cv2
import tensorflow as tf
from tensorflow.keras.models import load_model
from sklearn.model_selection import train_test_split
from tensorflow.keras import backend as K
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
import tensorflow.keras
from tensorflow.keras.callbacks import ModelCheckpoint
from sklearn.model_selection import KFold
import tensorflow.keras.metrics
from sklearn.metrics import make_scorer
from sklearn.metrics import roc_curve, auc
from sklearn.utils import shuffle
import warnings
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix
import seaborn as sn
import time
from sklearn.metrics import f1_score, roc_auc_score, precision_score, recall_score, balanced_accuracy_score, classification_report

def my_precision(y_true, y_pred):
    return precision_score(y_true, y_pred, average="binary",zero_division=1)

def my_recall(y_true, y_pred):
    return recall_score(y_true, y_pred, average="binary")

def my_f1(y_true, y_pred):
    return f1_score(y_true, y_pred, average=None)[1]

def my_roc_auc(y_true, y_pred):
    return roc_auc_score(y_true, y_pred, average=None)

def my_classification_report(y_true, y_pred):
    return classification_report(y_true, y_pred)

def get_specificity(balanced_acc,recall_arr):
    return 2*(np.asarray(balanced_acc))-(np.asarray(recall_arr))

def get_balanced_acc(y_true, y_pred):
    return balanced_accuracy_score(y_true, y_pred)

def plotConfusionMatrix(y_true,y_pred):
    conf_matrix = confusion_matrix(y_true,y_pred)
    norm_array = conf_matrix.astype('float') / conf_matrix.sum(axis=1)[:,np.newaxis]
    group_counts = ["{0:0.0f}".format(value) for value in conf_matrix.flatten()]
    group_percentages = ["{0:.2%}".format(value) for value in norm_array.flatten()]
    labels = [f"{v1}\n\n{v2}" for v1, v2 in zip(group_counts,group_percentages)]
    labels = np.asarray(labels).reshape(2,2)
    df_cm = pd.DataFrame(conf_matrix, range(2), range(2))
    ax = sn.heatmap(df_cm, annot=labels,fmt='', cmap='Greens')
    ax.set_title('CNN model confusion matrix');
    ax.set_xlabel('Predicted Values')
    ax.set_ylabel('Actual Values');
    ## Ticket labels - List must be in alphabetical order
    ax.xaxis.set_ticklabels(['Non-Likely-COVID-19','Likely-COVID-19'])
    ax.yaxis.set_ticklabels(['Non-Likely-COVID-19','Likely-COVID-19'],va="center")
    plt.show()
    
def plotCurves(title,x,y,curve,histories):
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

def progressBar(iterable, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█', printEnd = "\r"):
    total = len(iterable)
    # Progress Bar Printing Function
    def printProgressBar (iteration):
        percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
        filledLength = int(length * iteration // total)
        bar = fill * filledLength + '-' * (length - filledLength)
        print(f'\r{prefix} |{bar}| {percent}% {suffix}', end = printEnd)
    printProgressBar(0)
    for i, item in enumerate(iterable):
        yield item
        printProgressBar(i + 1)
    print()

path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\aug_mel_test_data\\"
names = sorted(os.listdir(path), key=lambda x: int(os.path.splitext(x)[0]))
imgArraySize = (88,39)

# Loading Images

images = []
for filename in progressBar(names, prefix = 'Reading:', suffix = '', length = 50):
    img = cv2.imread(os.path.join(path,filename))
    img = cv2.resize(img,imgArraySize)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = np.asarray(img,dtype=np.float32)
    img = img/225.0
    if img is not None:
        images.append(img)

images = np.squeeze(images)
# Loading Labels
labels = pd.read_csv('C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\aug_labels.csv')
labels.columns = ['label']
covid_status = labels["label"]
covid_status = np.asarray(covid_status)

model = load_model("Augmented_2_Classes_Model.hdf5")
score = model.evaluate(images,covid_status, verbose=0)
covPredict = model.predict(images)
covPredict = np.where(covPredict >= 0.5, 1,0)

print("Precision : ", my_precision(covid_status, covPredict))
print("Recall : ", my_recall(covid_status, covPredict))
print("F1 : ", my_f1(covid_status, covPredict))
print("ReportL ", my_classification_report(covid_status, covPredict))

## Plot confusion matrix
    
plotConfusionMatrix(covid_status,covPredict)


