import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import gc
import shutil
import cv2
import tensorflow as tf
import json
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
import time
from sklearn.metrics import f1_score, roc_auc_score, precision_score, recall_score, balanced_accuracy_score, classification_report

warnings.filterwarnings('always')

# finding precision of predicted values:
def my_precision(y_true, y_pred):
    return precision_score(y_true, y_pred, average='macro')

def my_recall(y_true, y_pred):
    return recall_score(y_true, y_pred, average='macro')

def my_f1(y_true, y_pred):
    return f1_score(y_true, y_pred, average="weighted")

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
        plt.plot(entry[curve], ls='dashed', alpha=0.2, color='tomato')
        train_all.append(entry[curve])
    train_all = np.array(train_all)
    train_avg = np.average(train_all, axis=0)
    plt.plot(train_avg, ls='-', lw=2, label='Average train ' + curve, color='tomato')
    val_all = []
    val_avg = []
    for entry in histories:
        plt.plot(entry['val_' + curve], ls='dashed', alpha=0.2, color='darkcyan')
        val_all.append(entry['val_' + curve])
    val_all = np.array(val_all)
    val_avg = np.average(val_all, axis=0)
    plt.plot(val_avg, ls='-', lw=2, label='Average validation ' + curve, color='darkcyan')
    plt.title(title)
    plt.ylabel(x)
    plt.xlabel(y)
    plt.legend(loc='best')
    plt.grid()
    plt.show()


path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_Mel\\"
names = sorted(os.listdir(path), key=lambda x: int(os.path.splitext(x)[0]))
imgArraySize = (88, 39)

images = []

for filename in progressBar(names, prefix='Reading:', suffix='', length=50):
    img = cv2.imread(os.path.join(path, filename))
    img = cv2.resize(img, imgArraySize)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = np.asarray(img, dtype=np.float32)
    img = img / 225.0
    if img is not None:
        images.append(img)

images = np.squeeze(images)

path_to_json = 'C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_JSON\\'
json_files = [pos_json for pos_json in os.listdir(path_to_json) if pos_json.endswith('.json')]
print(len(json_files))
covid_status = []

for j_file in json_files:
    with open(path_to_json + j_file, "r") as file:
        try:
            file_data = json.load(file, strict=False)
            file_name = os.path.splitext(j_file)[0]
            status = file_data['status']
            print(type(status))
            if status == "healthy":
                # file.seek(0)
                file.close()
                covid_status.append(-1)
            elif status == "symptomatic":
                # file.seek(0)
                file.close()
                covid_status.append(0)
            elif status == "COVID-19":
                # file.seek(0)
                file.close()
                covid_status.append(1)
        except json.JSONDecodeError as error:
            print("Empty response " + file_name)
            print(status)
            print(error)
            
covid_status = np.asarray(covid_status)

rows = imgArraySize[1]
cols = imgArraySize[0]

# trainx, valx, trainy, valy

print("Dataset count: ", len(images), " Shape: ", images.shape)
print("Labels count: ", len(covid_status), " Shape: ", covid_status.shape)

np.random.seed(75)

images, covid_status = shuffle(images, covid_status, random_state=75)
(trainX, testX, trainY, testY) = train_test_split(images, covid_status, test_size=0.2, shuffle=True)

# trainY = to_categorical(trainY)
# testY = to_categorical(testY)
# trainX = to_categorical(trainX)
# testX = to_categorical(testX)

if K.image_data_format() == 'channels_first':
    images = images.reshape(images.shape[0], 3, rows, cols)
    input_shape = (3, rows, cols)
else:
    images = images.reshape(images.shape[0], rows, cols, 3)
    input_shape = (rows, cols, 3)

num_folds = 10
fold_no = 1

kfold = KFold(n_splits=num_folds, shuffle=True, random_state=75)

METRICS = [
    tensorflow.keras.metrics.BinaryAccuracy(name='accuracy'),
    tensorflow.keras.metrics.Precision(name='precision'),
    tensorflow.keras.metrics.Recall(name='recall'),
]

acc_per_fold = []
recall_per_fold = []
precision_per_fold = []
f1_per_fold = []
loss_per_fold = []
histories = []

for train, test in kfold.split(trainX, trainY):
    epochs = 50
    batch_size = 256
    learning_rate = 0.001
    optimizer = tf.keras.optimizers.Adamax(learning_rate=learning_rate)
    # optimizer = tf.compat.v1.train.GradientDescentOptimizer(learning_rate = learning_rate)
    filepath = "model_best_weights_" + str(fold_no) + ".hdf5"
    checkpoint = ModelCheckpoint(filepath, monitor='val_accuracy', verbose=1, save_best_only=True, mode='max')
    # input layer
    inputs = Input(shape=input_shape, name='input')
    # first conv layer
    x = Conv2D(16, (2, 2), strides=(1, 1), padding='valid', kernel_initializer='normal')(inputs)
    x = AveragePooling2D((2, 2), strides=(1, 1))(x)
    x = BatchNormalization()(x)
    x = Activation('relu')(x)
    x = Dropout(0.2)(x)
    # second conv layer
    x = Conv2D(32, (2, 2), strides=(1, 1), padding="valid", kernel_initializer='normal')(x)
    x = AveragePooling2D((2, 2), strides=(1, 1))(x)
    x = BatchNormalization()(x)
    x = Activation('relu')(x)
    x = Dropout(0.2)(x)
    # third conv layer
    x = Conv2D(64, (2, 2), strides=(1, 1), padding="valid", kernel_initializer='normal')(x)
    x = AveragePooling2D((2, 2), strides=(1, 1))(x)
    x = BatchNormalization()(x)
    x = Activation('relu')(x)
    x = Dropout(0.2)(x)
    # fourth conv layer
    x = Conv2D(128, (2, 2), strides=(1, 1), padding="valid", kernel_initializer='normal')(x)
    x = AveragePooling2D((2, 2), strides=(1, 1))(x)
    x = BatchNormalization()(x)
    x = Activation('relu')(x)
    x = Dropout(0.2)(x)
    # reshaping the output
    td = Reshape([31, 80 * 128])(x)
    # LSTM layer with 256 neurons
    x = LSTM(256, return_sequences=False)(td)
    # activation and overfitting prevension layers
    x = Activation('tanh')(x)
    x = BatchNormalization()(x)
    x = Dropout(0.2)(x)
    x = Dense(100)(x)
    x = Activation('relu')(x)
    x = Dropout(0.5)(x)
    x = Dense(1, name='output_layer')(x)
    x = Activation('sigmoid')(x)
    # creating the model
    model = Model(inputs=inputs, outputs=x)
    model.compile(optimizer=optimizer, loss='mean_squared_error', metrics=METRICS)
    # starting the model
    start = time.time()
    history = model.fit(trainX[train], trainY[train], batch_size=batch_size, epochs=epochs, verbose=1,
                        validation_data=(trainX[test], trainY[test]), callbacks=[checkpoint])
    end = time.time()
    
    # scores for this fold
    histories.append(history)
    scores = model.evaluate(trainX[test], trainY[test], verbose=0)
    covPredict = model.predict(trainX[test])
    covPredict = np.where(covPredict >= 0.5, 1, 0)
    real_stat = trainY[test]
    acc_per_fold.append(scores[1])
    recall_per_fold.append(my_recall(real_stat, covPredict))
    precision_per_fold.append(my_precision(real_stat, covPredict))
    f1_per_fold.append(my_f1(real_stat, covPredict))
    loss_per_fold.append(scores[0])
    
    # testing the model
    model = load_model('model_best_weights_' + str(fold_no) + '.hdf5')
    
    # for trainY[test]
    score = model.evaluate(trainX[test], trainY[test], verbose=0)
    covPredict = model.predict(trainX[test])
    covPredict = np.where(covPredict >= 0.5, 1, 0)
    print("Validation results for the fold " + str(fold_no) + ":")
    print("Accuracy : ", score[1])
    print("Precision : ", my_precision(trainY[test], covPredict))
    print("Recall : ", my_recall(trainY[test], covPredict))
    print("F1 : ", my_f1(trainY[test], covPredict))
    
    # for testY
    score = model.evaluate(testX, testY, verbose=0)
    covPredict = model.predict(testX)
    covPredict = np.where(covPredict >= 0.5, 1, 0)
    print("Test results for the fold " + str(fold_no) + ":")
    print("Accuracy : ", score[1])
    print("Precision : ", my_precision(testY, covPredict))
    print("Recall : ", my_recall(testY, covPredict))
    print("F1 : ", my_f1(testY, covPredict))
    
    fold_no = fold_no + 1
    
print("Accuracy per fold : ", acc_per_fold)
print("Precision per fold : ", precision_per_fold)
print("Recall per fold : ", recall_per_fold)
print("F1 per fold : ", f1_per_fold)

print("Mean Accuracy : ", np.mean(acc_per_fold))
print("std Accuracy : ", np.std(acc_per_fold))
print("Mean Precision : ", np.mean(precision_per_fold))
print("std Precision : ", np.std(precision_per_fold))
print("Mean Recall : ", np.mean(recall_per_fold))
print("std Recall : ", np.std(recall_per_fold))
print("Mean F1 : ", np.mean(f1_per_fold))
print("std F1 : ", np.std(f1_per_fold))

### Use the index of the best obtained model according to the test results

best_model = 3

model = load_model('model_best_weights_' + str(best_model) + '.hdf5')
score = model.evaluate(testX, testY, verbose=0)
covPredict = model.predict(testX)
covPredict = np.where(covPredict >= 0.5, 1, 0)

## Plot accuracy curves
plotCurves('CNN-LSTM train and validation accuracy curves', 'Accuracy', 'Epoch', 'accuracy', histories)

## Plot loss curves
plotCurves('CNN-LSTM train and validation loss curves', 'Loss', 'Epoch', 'loss', histories)

## Plot Precision curves
plotCurves('CNN-LSTM train and validation precision curves', 'Precision', 'Epoch', 'precision', histories)
    
    
    
    
    