import sys

import tensorflow as tf
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import gc
import shutil
from PIL import Image
import cv2
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
from tensorflow.keras.layers import Flatten
import tensorflow.keras
from tensorflow.keras.callbacks import ModelCheckpoint
from sklearn.model_selection import KFold
import tensorflow.keras.metrics
from sklearn.metrics import make_scorer
from sklearn.metrics import roc_curve, auc
from sklearn.utils import shuffle
import warnings
import time
from sklearn.metrics import f1_score, roc_auc_score, precision_score, recall_score, balanced_accuracy_score, \
    classification_report
from sklearn.metrics import confusion_matrix
import seaborn as sn
from attention_layer import AttentionLayer


#labels=np.unique(y_pred)
# finding precision of predicted values:
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


#  

warnings.filterwarnings('always')

# Useful functions

path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_Mel_Matlab\\"
names = sorted(os.listdir(path), key=lambda x: int(os.path.splitext(x)[0]))



# Loading Images

    # left = 53.5
    # top = 34.55
    # right = 323.4
    # bottom = 233.6
# len(names)

for n in range(len(names)):
    image = Image.open(path+names[n])
    left = 154
    top = 67
    right = 1088
    bottom = 803
    img_res = image.crop((left, top, right, bottom))
    # img_res.show()
    img_res.save(".\\mels\\" + names[n])

new_path = ".\\mels\\"
names = sorted(os.listdir(new_path), key=lambda x: int(os.path.splitext(x)[0]))

# img = Image.open(new_path+names[0])
# width, height = img.size

imgArraySize = (39, 88)

images = []

for filename in progressBar(names, prefix='Reading:', suffix='', length=50):
    img = cv2.imread(os.path.join(new_path, filename))
    img = cv2.resize(img, imgArraySize)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = np.asarray(img, dtype=np.float32)
    img = img / 225.0
    # print(sys.getsizeof(img))
    if img is not None:
        images.append(img)




# for n in range(10):
#     # printing the img
#     print("The Image is : ")
#     print(sys.getsizeof(images[n]))
#     for i in images[n]:
#         for j in i:
#             print(j, end=' ')
#     print("\n\n")
# # print(images)
images = np.squeeze(images)

path_to_json = 'C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Experiment_JSON_Matlab\\'
json_files = [pos_json for pos_json in os.listdir(path_to_json) if pos_json.endswith('.json')]
# print(len(json_files))
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

# print(images)
# print(covid_status)

rows = imgArraySize[1]
cols = imgArraySize[0]

if K.image_data_format() == 'channels_first':
    images = images.reshape(images.shape[0],3,rows,cols)
    input_shape = (3, rows, cols)
else:
    images = images.reshape(images.shape[0],rows,cols,3)
    input_shape = (rows, cols,3)
    
    
print("Dataset count: ", len(images), " Shape: ", images.shape)
print("Labels count: ", len(covid_status), " Shape: ", covid_status.shape)
    
# print("Sample:")
# plt.imshow(images[0])
# print("Label: ", covid_status[0])

np.random.seed(75)

images, covid_status = shuffle(images, covid_status, random_state=75)
(trainX, testX, trainY, testY) = train_test_split(images, covid_status, test_size=0.2, shuffle=True)

del images, covid_status

print("Train set size : ", len(trainX))
print("Test set size : ", len(testX))

original_trainY = trainY
original_testY = testY
trainY = tf.keras.utils.to_categorical(trainY, 3)
testY = tf.keras.utils.to_categorical(testY, 3)

## Evaluation metrics

scoring = {'accuracy': 'accuracy',
            'precision': make_scorer(my_precision),
            'recall': make_scorer(my_recall),
            'f1': make_scorer(my_f1)}

## Start 10-fold cross-validation

# num_folds = 10
# fold_no = 1

# acc_per_fold = []
# recall_per_fold = []
# precision_per_fold = []
# f1_per_fold = []
# loss_per_fold = []
histories = []

METRICS = [
    'accuracy',
    tensorflow.keras.metrics.Precision(name='precision'),
    tensorflow.keras.metrics.Recall(name='recall'),
]

# kfold = KFold(n_splits=num_folds, shuffle=True, random_state=75)

# for train, test in kfold.split(trainX, trainY):
epochs = 10
batch_size = 150
learning_rate = 0.001
# optimizer = tf.keras.optimizers.Adamax(learning_rate=learning_rate)
optimizer = tf.keras.optimizers.RMSprop(learning_rate=learning_rate)
# filepath = "model_best_weights_" + str(fold_no) + ".hdf5"

filepath = 'Matlab_cropped_NoFolds_RMSprop_Optim_point2_lastD_001' + '.hdf5'

checkpoint = ModelCheckpoint(filepath, monitor='val_accuracy', verbose=1, save_best_only=True, mode='max')
# Model architecture
print('------------------------------------------------------------------------')
# print(f'Training for fold {fold_no} ...')

print('Training for Train Test without Fold ...')

inputs = Input(shape=input_shape, name='input')
x = Conv2D(16, (2, 2), strides=(1, 1), padding='valid', kernel_initializer='normal')(inputs)
x = AveragePooling2D((2, 2), strides=(1, 1))(x)
# x = BatchNormalization()(x)
x = Activation('relu')(x)
x = Dropout(0.2)(x)
x = Conv2D(32, (2, 2), strides=(1, 1), padding="valid", kernel_initializer='normal')(x)
x = AveragePooling2D((2, 2), strides=(1, 1))(x)
# x = BatchNormalization()(x)
x = Activation('relu')(x)
x = Dropout(0.2)(x)
x = Conv2D(64, (2, 2), strides=(1, 1), padding="valid", kernel_initializer='normal')(x)
x = AveragePooling2D((2, 2), strides=(1, 1))(x)
# x = BatchNormalization()(x)
x = Activation('relu')(x)
x = Dropout(0.2)(x)
x = Conv2D(128, (2, 2), strides=(1, 1), padding="valid", kernel_initializer='normal')(x)
x = AveragePooling2D((2, 2), strides=(1, 1))(x)
x = BatchNormalization()(x)
x = Activation('relu')(x)
x = Dropout(0.2)(x)
td = Reshape([31, 80 * 128])(x)
x = LSTM(256, return_sequences=False)(td)
x = Activation('relu')(x)
x = BatchNormalization(momentum=0.9)(x)
x = Dropout(0.2)(x)
x = AttentionLayer(return_sequences=False)(x)
x = Dense(100)(x)
x = Activation('relu')(x)
x = Dropout(0.2)(x)
x = Dense(3, name='output_layer')(x)
x = Activation('softmax')(x)
model = Model(inputs=inputs, outputs=x)


# inputs = Input(shape=input_shape,name='input')
# x = Conv2D(16, (2, 2), strides=(1, 1), padding='valid', kernel_initializer='normal')(inputs)
# x = AveragePooling2D((2, 2), strides=(1, 1))(x)
# # x = BatchNormalization()(x)
# x = Activation('relu')(x)
# x = Dropout(0.2)(x)
# x = Conv2D(32, (2, 2), strides=(1, 1), padding="valid", kernel_initializer='normal')(x)
# x = AveragePooling2D((2, 2), strides=(1, 1))(x)
# # x = BatchNormalization()(x)
# x = Activation('relu')(x)
# x = Dropout(0.2)(x)
# x = Conv2D(64, (2, 2), strides=(1, 1), padding="valid", kernel_initializer='normal')(x)
# x = AveragePooling2D((2, 2), strides=(1, 1))(x)
# # x = BatchNormalization()(x)
# x = Activation('relu')(x)
# x = Dropout(0.2)(x)
# x = Conv2D(128, (2, 2), strides=(1, 1), padding="valid", kernel_initializer='normal')(x)
# x = AveragePooling2D((2, 2), strides=(1, 1))(x)
# # x = BatchNormalization()(x)
# x = Activation('relu')(x)
# x = Dropout(0.2)(x)
# x = Flatten()(x)
# x = Dense(32)(x)
# x = Activation('relu')(x)
# x = Dropout(0.5)(x)
# x = Dense(3, name='output_layer')(x)
# x = Activation('softmax')(x)
# model = Model(inputs=inputs, outputs=x)


# model = tf.keras.models.Sequential([
    
# tf.keras.layers.Conv2D(16, (2, 2), strides=(1, 1), activation='relu', padding='valid', kernel_initializer='normal', input_shape=input_shape),
# tf.keras.layers.AveragePooling2D((2, 2), strides=(1, 1)),
# tf.keras.layers.Conv2D(32, (2, 2), strides=(1, 1), activation='relu', padding="valid", kernel_initializer='normal'),
# tf.keras.layers.AveragePooling2D((2, 2), strides=(1, 1)),
# tf.keras.layers.Conv2D(64, (2, 2), strides=(1, 1), activation='relu', padding="valid", kernel_initializer='normal'),
# tf.keras.layers.MaxPooling2D(2,2),
# tf.keras.layers.Conv2D(128, (2, 2), strides=(1, 1), activation='relu', padding="valid", kernel_initializer='normal'),
# tf.keras.layers.AveragePooling2D((2, 2), strides=(1, 1)),

# tf.keras.layers.Dense(1024, activation='relu'),
# tf.keras.layers.Dropout(0.2),
# tf.keras.layers.Dense(512, activation="relu"),
# tf.keras.layers.Dropout(0.2), 

# tf.keras.layers.Dense(3, activation="softmax")
# ])

model.compile(optimizer=optimizer, loss="categorical_crossentropy", metrics=METRICS)
start = time.time()
# history = model.fit(trainX[train], trainY[train], batch_size=batch_size, epochs=epochs, verbose=1,
#                     validation_data=(trainX[test], trainY[test]), callbacks=[checkpoint])

# , activation="softmax"

print("Train Data Shape for Training: ")
print(trainX.shape)
print("Train Data Labels Shape for Training: ")
print(trainY.shape)

print("Test Data Shape for Testing: ")
print(testX.shape)
print("Test Data Labels Shape for Testing: ")
print(testY.shape)

history = model.fit(trainX, trainY, batch_size=batch_size, epochs=epochs, verbose=1,
                    validation_data=(testX, testY), callbacks=[checkpoint])

end = time.time()
print("Training time : ", (end - start))
histories.append(history)
# scores = model.evaluate(trainX[test], trainY[test], verbose=0)

scores = model.evaluate(testX, testY, verbose=0)

# covPredict = model.predict(trainX[test])

covPredict = model.predict(testX)
predictions = []
for n in range(len(covPredict)):
    predictions.append(np.argmax(covPredict[n]))

covPredict = predictions

for i in covPredict:
    print(i, end=", ")

print("")
# covPredict = np.where(covPredict >= 0.5, 1, 0)

# real_stat = trainY[test]

real_stat = testY

print("Accuracy : ", scores[1])
print("Precision : ", my_precision(original_testY, covPredict))
print("Recall : ", my_recall(original_testY, covPredict))
print("F1 : ", my_f1(original_testY, covPredict))
print("ReportL ", my_classification_report(original_testY, covPredict))

# acc_per_fold.append(scores[1])
# recall_per_fold.append(my_recall(real_stat, covPredict))
# precision_per_fold.append(my_precision(real_stat, covPredict))
# f1_per_fold.append(my_f1(real_stat, covPredict))
# loss_per_fold.append(scores[0])
# model = load_model('model_best_weights_' + str(fold_no) + '.hdf5')

# model = load_model('training_without_folds_RMSprop_Optim' + '.hdf5')

# # fold testing

# # score = model.evaluate(trainX[test], trainY[test], verbose=0)
# # covPredict = model.predict(trainX[test])
# # covPredict = np.where(covPredict >= 0.5, 1, 0)
# # print("Validation results for the fold " + str(fold_no) + ":")
# # print("Accuracy : ", score[1])
# # print("Precision : ", my_precision(trainY[test], covPredict))
# # print("Recall : ", my_recall(trainY[test], covPredict))
# # print("F1 : ", my_f1(trainY[test], covPredict))
# # print("ReportL ", my_classification_report(trainY[test], covPredict))

# # test set testing
# score = model.evaluate(testX, testY, verbose=0)
# covPredict = model.predict(testX)


# # covPredict = np.where(covPredict >= 0.5, 1, 0)
# predictions = []
# for n in range(len(covPredict)):
#     predictions.append(np.argmax(covPredict[n]))

# covPredict = predictions

# for i in covPredict:
#     print(i, end=", ")

# print("")

# # print("Test results for the fold " + str(fold_no) + ":")
# print("Accuracy : ", score[1])
# print("Precision : ", my_precision(original_testY, covPredict))
# print("Recall : ", my_recall(original_testY, covPredict))
# print("F1 : ", my_f1(original_testY, covPredict))
# print("ReportL ", my_classification_report(original_testY, covPredict))
# fold_no = fold_no + 1

# print("Accuracy per fold : ", acc_per_fold)
# print("Precision per fold : ", precision_per_fold)
# print("Recall per fold : ", recall_per_fold)
# print("F1 per fold : ", f1_per_fold)

# print("Mean Accuracy : ", np.mean(acc_per_fold))
# print("std Accuracy : ", np.std(acc_per_fold))
# print("Mean Precision : ", np.mean(precision_per_fold))
# print("std Precision : ", np.std(precision_per_fold))
# print("Mean Recall : ", np.mean(recall_per_fold))
# print("std Recall : ", np.std(recall_per_fold))
# print("Mean F1 : ", np.mean(f1_per_fold))
# print("std F1 : ", np.std(f1_per_fold))

### Use the index of the best obtained model according to the test results

# best_model = 1

# model = load_model('model_best_weights_' + str(best_model) + '.hdf5')
# score = model.evaluate(testX, testY, verbose=0)
# covPredict = model.predict(testX)
# covPredict = np.where(covPredict >= 0.5, 1, 0)

# Plot accuracy curves
plotCurves('CNN-LSTM train and validation accuracy curves', 'Accuracy', 'Epoch', 'accuracy', histories)

# Plot loss curves
plotCurves('CNN-LSTM train and validation loss curves', 'Loss', 'Epoch', 'loss', histories)

# Plot Precision curves
plotCurves('CNN-LSTM train and validation precision curves', 'Precision', 'Epoch', 'precision', histories)

# for n in range(len(histories)):
#     plt.plot(histories[n]['val_accuracy'], "r", histories[n]['val_loss'], "b", histories[n]['val_precision'], "g")
#     plt.show()

# Plot confusion matrix
plotConfusionMatrix(original_testY, covPredict)