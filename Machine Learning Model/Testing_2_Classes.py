# -*- coding: utf-8 -*-
"""
Created on Mon Dec 26 21:11:06 2022

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
# from utils import my_precision,my_recall,my_f1,my_roc_auc,get_specificity,get_balanced_acc,plotConfusionMatrix,plotCurves,progressBar,plotROCCurve

warnings.filterwarnings('always')

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

testing_data_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\Split Data\\Testing\\mels\\"
testing_names = sorted(os.listdir(testing_data_path), key=lambda x: int(os.path.splitext(x)[0]))
imgArraySize = (88,39)


# Loading Testing Labels
labels = pd.read_csv('C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\Split Data\\Testing\\labels.csv')
labels.columns = ['label']
testing_covid_status = labels["label"]
testing_covid_status = np.asarray(testing_covid_status)


# Loading Testing Images
testing_images = []
for filename in progressBar(testing_names, prefix = 'Reading:', suffix = '', length = 50):
    img = cv2.imread(os.path.join(testing_data_path,filename))
    img = cv2.resize(img,imgArraySize)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = np.asarray(img,dtype=np.float32)
    img = img/225.0
    if img is not None:
        testing_images.append(img)

testing_images = np.squeeze(testing_images)

rows = imgArraySize[1]
cols = imgArraySize[0]

if K.image_data_format() == 'channels_first':
    testing_images = testing_images.reshape(testing_images.shape[0],3,rows,cols)
    input_shape = (3, rows, cols)
else:
    testing_images = testing_images.reshape(testing_images.shape[0],rows,cols,3)
    input_shape = (rows, cols,3)

print("Testing Dataset count: ",len(testing_images)," Shape: ",testing_images.shape)
print("Testing Labels count: ",len(testing_covid_status)," Shape: ",testing_covid_status.shape)

model = load_model("C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Models_KFold\\2_Classes\\Augmented_2_Classes_Model_2nd_Trial_02.hdf5")
score = model.evaluate(testing_images,testing_covid_status, verbose=0)
covPredict = model.predict(testing_images)
covPredict = np.where(covPredict >= 0.5, 1,0)

print("Precision : ", my_precision(testing_covid_status, covPredict))
print("Recall : ", my_recall(testing_covid_status, covPredict))
print("F1 : ", my_f1(testing_covid_status, covPredict))
print("ReportL ", my_classification_report(testing_covid_status, covPredict))

## Plot confusion matrix
plotConfusionMatrix(testing_covid_status,covPredict)

