# -*- coding: utf-8 -*-
"""
Created on Fri Feb 10 15:52:23 2023

@author: Ayah Abdel-Ghani
"""

import tsfel
import os
import librosa
import pandas as pd
import numpy as np
import librosa.display
import matplotlib.pyplot as plt
import tensorflow as tf
import tensorflow_io as tfio
import csv


# path to training and testing data as images

training_data_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Training_Wav_Set\\wavs\\"
testing_data_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\wavs\\"
training_names = os.listdir(training_data_path)
testing_names = os.listdir(testing_data_path)

# Loading Training Labels
labels = pd.read_csv('C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Training_Wav_Set\\labels.csv')
labels.columns = ['label']
training_covid_status = labels["label"]
training_covid_status = np.asarray(training_covid_status)

# Loading Testing Labels
labels = pd.read_csv('C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\labels.csv')
labels.columns = ['label']
testing_covid_status = labels["label"]
testing_covid_status = np.asarray(testing_covid_status)

# Y = pd.DataFrame(rows = ['features'])
# Z = pd.DataFrame(rows = ['features'])

path_to_training_CSV = 'C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Training_Wav_Set\\features.csv'
path_to_testing_CSV = 'C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\features.csv'

training_f = open(path_to_training_CSV, 'w')
testing_f =  open(path_to_testing_CSV, 'w')

training_writer = csv.writer(training_f)
testing_writer = csv.writer(testing_f)

for i in range(1):
    X , rate = librosa.load(training_data_path+training_names[i])
    cfg = tsfel.get_features_by_domain()
    features = tsfel.time_series_features_extractor(cfg, X)
    training_writer.writerow(features.columns)

for wav_name in training_names:
    X , rate = librosa.load(training_data_path+wav_name)
    cfg = tsfel.get_features_by_domain()
    features = tsfel.time_series_features_extractor(cfg, X)
    training_writer.writerow(features.values)
    print("still in writing training")

print("Finished Training")

for i in range(1):
    X , rate = librosa.load(training_data_path+testing_names[i])
    cfg = tsfel.get_features_by_domain()
    features = tsfel.time_series_features_extractor(cfg, X)
    testing_writer.writerow(features.columns)

for testing_wav_name in testing_names:
    X , rate = librosa.load(testing_data_path+testing_wav_name)
    cfg = tsfel.get_features_by_domain()
    features = tsfel.time_series_features_extractor(cfg, X)
    testing_writer.writerow(features.values)
    print("still in writing testing")

print("Finished Testing")


















