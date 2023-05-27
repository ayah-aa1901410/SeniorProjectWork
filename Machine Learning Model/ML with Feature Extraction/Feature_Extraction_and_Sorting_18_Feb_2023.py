# -*- coding: utf-8 -*-
"""
Created on Sat Feb 18 18:15:18 2023

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

training_wavs_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Training_Wav_Set\\wavs\\"
testing_wavs_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\wavs\\"

training_features_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Training_Wav_Set\\features.csv"
testing_features_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\features.csv"

training_label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Training_Wav_Set\\labels.csv"
testing_label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\labels.csv"

"""
This code is for the Feature Extraction of the Training and Testing Samples

The Features will be saved in a CSV file called features.csv in each of the folders.

The Labels associated with the features are in 

"""

Y = pd.DataFrame(columns = ['label'])
Z = pd.DataFrame(columns = ['label'])

training_f = open(training_features_path, 'w', newline='')
testing_f =  open(testing_features_path, 'w', newline='')

training_writer = csv.writer(training_f)
testing_writer = csv.writer(testing_f)

cfg = tsfel.get_features_by_domain()

training_names = os.listdir(training_wavs_path)
testing_names = os.listdir(testing_wavs_path)

print("Starting the Feature Extraction: ")

n=0

for wav_name in training_names:
    if os.stat(training_wavs_path+wav_name).st_size != 0:
        X , rate = librosa.load(training_wavs_path+wav_name)
        features = tsfel.time_series_features_extractor(cfg, np.trim_zeros(X),verbose=0)
        training_writer.writerow(features.values[0].tolist())
        label = wav_name.split('.')[0].split('_')[1]
        Y = Y.append({'label':label},ignore_index=True)
        n=n+1
        print("")
        print("Done Sample no. ")
        print(n)
        print("")


# for wav_name in range(3):
#     if os.stat(training_wavs_path+training_names[wav_name]).st_size != 0:
#         X , rate = librosa.load(training_wavs_path+training_names[wav_name])
#         features = tsfel.time_series_features_extractor(cfg, np.trim_zeros(X),verbose=0)
#         training_writer.writerow(features.values[0].tolist())
#         label = training_names[wav_name].split('.')[0].split('_')[1]
#         Y = Y.append({'label':label},ignore_index=True)
#         n=n+1
#         print("")
#         print("Done Sample no. ")
#         print(n)
#         print("")
    
Y.to_csv(training_label_path,index=False)
print("Finished Training Samples")

training_f.close()

m=0
for testing_wav_name in testing_names:
    if os.stat(testing_wavs_path+testing_wav_name).st_size != 0:
        X , rate = librosa.load(testing_wavs_path+testing_wav_name)
        features = tsfel.time_series_features_extractor(cfg, np.trim_zeros(X),verbose=0)
        testing_writer.writerow(features.values[0].tolist())
        label = testing_wav_name.split('.')[0].split('_')[1]
        Z = Z.append({'label':label},ignore_index=True)
        m=m+1
        print("")
        print("Done Sample no. ")
        print(m)
    
Z.to_csv(testing_label_path,index=False)
print("Finished Testing Samples")

testing_f.close()

"""

Here is the code for the Feature Importance

"""

# training_f = open(training_features_path, 'r')
# testing_f =  open(testing_features_path, 'r')

# training_features = []
# testing_features = []

# with open(training_features_path) as training_file_obj:
#     training_reader = csv.reader(training_file_obj)
#     for row in training_reader:
#         training_features.append(row)

# with open(testing_features_path) as testing_file_obj:
#     testing_reader = csv.reader(testing_file_obj)
#     for row in testing_reader:
#         testing_features.append(row)


# print(str(len(training_features)) + " x " + str(len(training_features[0])))
# print(str(len(testing_features)) + " x " + str(len(testing_features[0])))

# print(training_features[0])



























