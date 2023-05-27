# -*- coding: utf-8 -*-
"""
Created on Sun Dec 11 11:26:28 2022

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
    
def plotROCCurve(fpr,tpr,auc,color,label,title):
    plt.figure(figsize=(14,8))
    ax = plt.gca()
    ax.set_facecolor((1.0, 1.0, 1.0))
    ax.patch.set_edgecolor('black')
    ax.patch.set_linewidth('2')  
    ax.grid(b=True, which='major', color='grey', linestyle='-', alpha=0.3)
    plt.plot(fpr,tpr, lw=2, label= label+' (area = {:.3f})'.format(auc),color = color)
    plt.plot([0, 1], [0, 1], '--',color='grey',label='Random model')
    plt.xlabel('False positive rate')
    plt.ylabel('True positive rate')
    plt.title(title)
    legend = plt.legend(loc="best", edgecolor="grey")
    legend.get_frame().set_alpha(None)
    legend.get_frame().set_facecolor((1, 1, 1, 0.7))
    plt.show()

#### Useful functions

path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\Split Data\\Training\\mels\\"
testing_data_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\Split Data\\Testing\\mels\\"
training_names = sorted(os.listdir(path), key=lambda x: int(os.path.splitext(x)[0]))
testing_names = sorted(os.listdir(testing_data_path), key=lambda x: int(os.path.splitext(x)[0]))
imgArraySize = (88,39)


# Loading Training Labels
labels = pd.read_csv('C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\Split Data\\Training\\labels.csv')
labels.columns = ['label']
training_covid_status = labels["label"]
training_covid_status = np.asarray(training_covid_status)

# Loading Testing Labels
labels = pd.read_csv('C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\Split Data\\Testing\\labels.csv')
labels.columns = ['label']
testing_covid_status = labels["label"]
testing_covid_status = np.asarray(testing_covid_status)


# LoadingTraining Images

training_images = []
for filename in progressBar(training_names, prefix = 'Reading:', suffix = '', length = 50):
    img = cv2.imread(os.path.join(path,filename))
    img = cv2.resize(img,imgArraySize)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = np.asarray(img,dtype=np.float32)
    img = img/225.0
    if img is not None:
        training_images.append(img)

training_images = np.squeeze(training_images)

# LoadingTraining Images

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
    training_images = training_images.reshape(training_images.shape[0],3,rows,cols)
    testing_images = testing_images.reshape(testing_images.shape[0],3,rows,cols)
    input_shape = (3, rows, cols)
else:
    training_images = training_images.reshape(training_images.shape[0],rows,cols,3)
    testing_images = testing_images.reshape(testing_images.shape[0],rows,cols,3)
    input_shape = (rows, cols,3)
    
print("Trainig Dataset count: ",len(training_images)," Shape: ",training_images.shape)
print("Training Labels count: ",len(training_covid_status)," Shape: ",training_covid_status.shape)

print("Testing Dataset count: ",len(testing_images)," Shape: ",testing_images.shape)
print("Testing Labels count: ",len(testing_covid_status)," Shape: ",testing_covid_status.shape)

np.random.seed(75)


# training_images,training_covid_status = shuffle(training_images,training_covid_status, random_state=75)

(trainingX,valX,trainingY,valY) = train_test_split(training_images,training_covid_status,test_size=0.15,shuffle=True)


## Evaluation metrics

scoring = {'accuracy': 'accuracy',
            'precision': make_scorer(my_precision),
            'recall':make_scorer(my_recall),
            'roc_auc':make_scorer(my_roc_auc),
            'f1':make_scorer(my_f1),
            'balanced_accuracy': 'balanced_accuracy'}

## Start 10-fold cross-validation

# num_folds = 5
# fold_no = 1

# acc_per_fold = []
# recall_per_fold = []
# precision_per_fold = []
# roc_auc_per_fold = []
# f1_per_fold = []
# balanced_acc = []
# specificity_per_fold = []
# loss_per_fold = []
histories = []

METRICS = [
    tensorflow.keras.metrics.BinaryAccuracy(name='accuracy'),
    tensorflow.keras.metrics.Precision(name='precision'),
    tensorflow.keras.metrics.Recall(name='recall'),
    tensorflow.keras.metrics.AUC(name='AUC')
]

# kfold = KFold(n_splits=num_folds, shuffle=True,random_state=75)

# for train,test in kfold.split(training_images,training_covid_status):
    
epochs = 150
batch_size = 256
learning_rate = 0.001
optimizer = tensorflow.keras.optimizers.Adamax(learning_rate = learning_rate)
# filepath='Models_KFold\\2_Classes\\Augmented_2_Classes_Model_2nd_Trial_0'+str(fold_no)+'.hdf5'
filepath= "Models_KFold\\2_Classes\\Augmented_02_2_Classes_Model_Last_trial.hdf5"
checkpoint = ModelCheckpoint(filepath, monitor='val_accuracy', verbose=1, save_best_only=True, mode='max')
###### Model architecture
print('------------------------------------------------------------------------')
# print(f'Training for fold {fold_no} ...')
inputs = Input(shape=input_shape,name='input')
x = Conv2D(16,(2,2),strides=(1,1),padding='valid',kernel_initializer='normal')(inputs)
x = AveragePooling2D((2,2), strides=(1,1))(x)
x = BatchNormalization()(x)
x = Activation('relu')(x)
x = Dropout(0.2)(x)
x = Conv2D(32,(2,2), strides=(1, 1), padding="valid",kernel_initializer='normal')(x)
x = AveragePooling2D((2,2), strides=(1,1))(x)
x = BatchNormalization()(x)
x = Activation('relu')(x)
x = Dropout(0.2)(x)
x = Conv2D(64,(2,2), strides=(1, 1), padding="valid",kernel_initializer='normal')(x)
x = AveragePooling2D((2,2), strides=(1,1))(x)
x = BatchNormalization()(x)
x = Activation('relu')(x)
x = Dropout(0.2)(x)
x = Conv2D(128,(2,2), strides=(1, 1), padding="valid",kernel_initializer='normal')(x)
x = AveragePooling2D((2,2), strides=(1,1))(x)
x = BatchNormalization()(x)
x = Activation('relu')(x)
x = Dropout(0.2)(x)
td = Reshape([31,80*128])(x)
x = LSTM(256, return_sequences=False)(td)
x = Activation('tanh')(x)
x = BatchNormalization()(x)
x = Dropout(0.2)(x)
x = Dense(100)(x)
x = Activation('relu')(x)
x = Dropout(0.5)(x)
x = Dense(1,name='output_layer')(x)
x = Activation('sigmoid')(x)
model = Model(inputs=inputs, outputs=x)
model.compile(optimizer=optimizer, loss="binary_crossentropy", metrics=METRICS)
start = time.time()
# history = model.fit(training_images[train], training_covid_status[train], batch_size=batch_size, epochs=epochs, verbose=1, validation_data=(training_images[test],training_covid_status[test]),callbacks=[checkpoint])
history = model.fit(trainingX, trainingY, batch_size=batch_size, epochs=epochs, verbose=1, validation_data=(valX, valY), callbacks=[checkpoint])

model.summary()

end = time.time()
print("Training time : ",(end-start))
histories.append(history)
    # scores = model.evaluate(training_images[test], training_covid_status[test], verbose=0)
    # covPredict = model.predict(training_images[test])
    # covPredict = np.where(covPredict >= 0.5, 1,0)
    # real_stat = training_covid_status[test]
    # acc_per_fold.append(scores[1])
    # recall_per_fold.append(my_recall(real_stat, covPredict))
    # precision_per_fold.append(my_precision(real_stat, covPredict))
    # roc_auc_per_fold.append(my_roc_auc(real_stat, covPredict))
    # f1_per_fold.append(my_f1(real_stat, covPredict))
    # balanced_acc.append(get_balanced_acc(real_stat, covPredict))
    # specificity_per_fold.append((2*get_balanced_acc(training_covid_status[test],covPredict))-my_recall(training_covid_status[test],covPredict))
    # loss_per_fold.append(scores[0])
    
    # model = load_model('Models_KFold\\2_Classes\\Augmented_2_Classes_Model_2nd_Trial_0'+str(fold_no)+'.hdf5')
    # score = model.evaluate(training_images[test],training_covid_status[test], verbose=0)
    # covPredict = model.predict(training_images[test])
    # covPredict = np.where(covPredict >= 0.5, 1,0)
    # print("Validation results for the fold "+str(fold_no)+":")
    # print("Accuracy : ",score[1])
    # print("Precision : ",my_precision(training_covid_status[test],covPredict))
    # print("Recall : ",my_recall(training_covid_status[test],covPredict))
    # print("F1 : ",my_f1(training_covid_status[test],covPredict))
    # print("ROC AUC : ",my_roc_auc(training_covid_status[test],covPredict))
    # print("Specificity : ",(2*get_balanced_acc(training_covid_status[test],covPredict))-my_recall(training_covid_status[test],covPredict))
    # score = model.evaluate(testing_images,testing_covid_status,verbose=0)
    # covPredict = model.predict(testing_images)
    # covPredict = np.where(covPredict >= 0.5, 1,0)
    # print("Test results for the fold "+str(fold_no)+":")
    # print("Accuracy : ",score[1])
    # print("Precision : ",my_precision(testing_covid_status,covPredict))
    # print("Recall : ",my_recall(testing_covid_status,covPredict))
    # print("F1 : ",my_f1(testing_covid_status,covPredict))
    # print("ROC AUC : ",my_roc_auc(testing_covid_status,covPredict))
    # print("Specificity : ",(2*get_balanced_acc(testing_covid_status,covPredict))-my_recall(testing_covid_status,covPredict))
    # fold_no = fold_no + 1
    # if(fold_no == 10):
    #     model.summary() 

    # print("Accuracy per fold : ",acc_per_fold)
    # print("Precision per fold : ",precision_per_fold)
    # print("Recall per fold : ",recall_per_fold)
    # print("ROC AUC per fold : ",roc_auc_per_fold)
    # print("F1 per fold : ",f1_per_fold)
    # print("Specificity per fold : ",specificity_per_fold)
    
    # print("Mean Accuracy : ",np.mean(acc_per_fold))
    # print("std Accuracy : ",np.std(acc_per_fold))
    # print("Mean Precision : ",np.mean(precision_per_fold))
    # print("std Precision : ",np.std(precision_per_fold))
    # print("Mean Recall : ",np.mean(recall_per_fold))
    # print("std Recall : ",np.std(recall_per_fold))
    # print("Mean ROC AUC : ",np.mean(roc_auc_per_fold))
    # print("std ROC AUC : ",np.std(roc_auc_per_fold))
    # print("Mean F1 : ",np.mean(f1_per_fold))
    # print("std F1 : ",np.std(f1_per_fold))
    # print("Mean Specificity : ",np.mean(get_specificity(balanced_acc,recall_per_fold)))
    # print("std Specificity : ",np.std(get_specificity(balanced_acc,recall_per_fold)))

### Use the index of the best obtained model according to the test results

best_model = 3

## Plot accuracy curves
plotCurves('CNN-LSTM train and validation accuracy curves','Accuracy','Epoch','accuracy',histories)

## Plot loss curves
plotCurves('CNN-LSTM train and validation loss curves','Loss','Epoch','loss',histories)

## Plot Sensitivity curves
plotCurves('CNN-LSTM train and validation sensitivity curves','Sensitivity','Epoch','recall',histories)

## Plot Precision curves
plotCurves('CNN-LSTM train and validation precision curves','Precision','Epoch','precision',histories)







# optimizer = tensorflow.keras.optimizers.Adamax(learning_rate = 0.001)
# inputs = Input(shape=input_shape,name='input')
# x = Conv2D(16,(2,2),strides=(1,1),padding='valid',kernel_initializer='normal')(inputs)
# x = AveragePooling2D((2,2), strides=(1,1))(x)
# x = BatchNormalization()(x)
# x = Activation('relu')(x)
# x = Dropout(0.2)(x)
# x = Conv2D(32,(2,2), strides=(1, 1), padding="valid",kernel_initializer='normal')(x)
# x = AveragePooling2D((2,2), strides=(1,1))(x)
# x = BatchNormalization()(x)
# x = Activation('relu')(x)
# x = Dropout(0.2)(x)
# x = Conv2D(64,(2,2), strides=(1, 1), padding="valid",kernel_initializer='normal')(x)
# x = AveragePooling2D((2,2), strides=(1,1))(x)
# x = BatchNormalization()(x)
# x = Activation('relu')(x)
# x = Dropout(0.2)(x)
# x = Conv2D(128,(2,2), strides=(1, 1), padding="valid",kernel_initializer='normal')(x)
# x = AveragePooling2D((2,2), strides=(1,1))(x)
# x = BatchNormalization()(x)
# x = Activation('relu')(x)
# x = Dropout(0.2)(x)
# td = Reshape([31,80*128])(x)
# x = LSTM(256, return_sequences=False)(td)
# x = Activation('tanh')(x)
# x = BatchNormalization()(x)
# x = Dropout(0.2)(x)
# x = Dense(100)(x)
# x = Activation('relu')(x)
# x = Dropout(0.5)(x)
# x = Dense(1,name='output_layer')(x)
# x = Activation('sigmoid')(x)
# model = Model(inputs=inputs, outputs=x)
# model.compile(optimizer=optimizer, loss="binary_crossentropy", metrics=METRICS)

# model.summary()






# model = load_model('Models_KFold\\2_Classes\\Augmented_2_Classes_Model_2nd_Trial_0'+str(best_model)+'.hdf5')
# model = load_model('Models_KFold\\2_Classes\\Augmented_2_Classes_Model_2nd_Trial_01'+'.hdf5')
model = load_model("Models_KFold\\2_Classes\\Augmented_02_2_Classes_Model_Last_trial.hdf5")
score = model.evaluate(testing_images,testing_covid_status, verbose=0)
covPredict = model.predict(testing_images)
covPredict = np.where(covPredict >= 0.5, 1,0)

print("Precision : ", my_precision(testing_covid_status, covPredict))
print("Recall : ", my_recall(testing_covid_status, covPredict))
print("F1 : ", my_f1(testing_covid_status, covPredict))
print("ReportL ", my_classification_report(testing_covid_status, covPredict))

## Plot confusion matrix
    
plotConfusionMatrix(testing_covid_status,covPredict)












# ## Plot ROC curve

# probabilities = model.predict(testing_covid_status).ravel()
# fpr, tpr, thresholds = roc_curve(testing_covid_status, probabilities, pos_label=1)
# auc = auc(fpr, tpr)
# plotROCCurve(fpr,tpr,auc,'darkgreen','CNN-LSTM ROC AUC ','CNN-LSTM baseline ROC AUC')


