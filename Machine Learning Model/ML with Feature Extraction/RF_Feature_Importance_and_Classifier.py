# -*- coding: utf-8 -*-
"""
Created on Sun Feb 19 15:55:13 2023

@author: Ayah Abdel-Ghani
"""

import numpy as np
import librosa 
import tsfel
import pandas as pd
from sklearn.ensemble import RandomForestRegressor,RandomForestClassifier
from sklearn.inspection import permutation_importance
import csv
import os
from sklearn.svm import SVC
from sklearn import preprocessing
from sklearn.preprocessing import StandardScaler

# Training / Testing Features and Labels Paths
training_wavs_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Training_Wav_Set\\wavs\\"
testing_wavs_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\wavs\\"


training_features_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Training_Wav_Set\\features.csv"
testing_features_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\features.csv"

training_label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Training_Wav_Set\\labels.csv"
testing_label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\labels.csv"

training_names = os.listdir(training_wavs_path)
testing_names = os.listdir(testing_wavs_path)

# Loading Training Labels
labels = pd.read_csv(training_label_path)
labels.columns = ['label']
training_labels = labels["label"]
training_labels = np.asarray(training_labels)

# Loading Testing Labels
labels = pd.read_csv(testing_label_path)
labels.columns = ['label']
testing_labels = labels["label"]
testing_labels = np.asarray(testing_labels)

# Opening the Features CSV files
training_file = open(training_features_path, 'r')
testing_file =  open(testing_features_path, 'r')

# Default TSFEL Features
cfg = tsfel.get_features_by_domain()

# The Random Forest Classifier
rf = RandomForestClassifier(max_depth=70)

# Getting the Training/Testing Features from the CSV Files
training_features = []
testing_features = []

with open(training_features_path) as training_file_obj:
    training_reader = csv.reader(training_file_obj)
    for row in training_reader:
        training_features.append(row)

with open(testing_features_path) as testing_file_obj:
    testing_reader = csv.reader(testing_file_obj)
    for row in testing_reader:
        testing_features.append(row)

# Checking the Sizes of the Training and Testing Sets
print(str(len(training_features)) + " x " + str(len(training_features[0])))
print(str(len(testing_features)) + " x " + str(len(testing_features[0])))

# Scaling the Testing and Training Features to pass to SVM

scaler = preprocessing.StandardScaler()
scaled_training_features = scaler.fit_transform(training_features)
scaled_testing_features = scaler.transform(testing_features)

# Feature Importance using Random Forest Classifier

# Fitting the Random Forest Classifier
model = rf.fit(training_features, training_labels)

features = []

for wav_name in range(1):
    if os.stat(training_wavs_path+training_names[wav_name]).st_size != 0:
        X , rate = librosa.load(training_wavs_path+training_names[wav_name])
        features = tsfel.time_series_features_extractor(cfg, np.trim_zeros(X),verbose=0)

feature_import = model.feature_importances_
sorted_indx = feature_import.argsort()

fi_len = len(feature_import)
r = len(sorted_indx)
r_r = len(feature_import[feature_import >= 0.01])

print(feature_import)
print("normal length: " + str(fi_len))
print("")

print(sorted_indx)
print("sorted length: " + str(r))
print("")

print(feature_import[feature_import >= 0.01])
print("normal with high threshold length: " + str(r_r))

# # Getting the Top Features using the Random Forest Classifier
# feature_importances = model.feature_importances_
# sorted_idx = feature_importances.argsort()
# threshold=0.01
# r = len(feature_importances[feature_importances>=threshold])
# top_features = np.array(training_features)[sorted_idx[-r:]]
# top_feature_importances = feature_importances[sorted_idx[-r:]]

# # Printing the Top Features for Checking Purposes
# print("Top Features")
# print(top_features)
# print(str(len(top_features)) + " x " + str(len(top_features[0])))
# print(type(top_features))

# print("Top Feature Importances")
# print(top_feature_importances)
# print(type(top_feature_importances))

# top_training = training_features[top_features] 
# top_testing = testing_features[top_features]

# print(top_training)
# print(top_testing)

# # svm = SVC()



# 







































