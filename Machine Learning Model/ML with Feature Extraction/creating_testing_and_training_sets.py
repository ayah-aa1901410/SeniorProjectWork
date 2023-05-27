# -*- coding: utf-8 -*-
"""
Created on Fri Feb 10 16:21:12 2023

@author: Ayah Abdel-Ghani
"""

# this code reads the list of wav files, shuffles the dataset, takes the first 2143 data and moves them with their labels to a new folder called the Testing_Wav_Set
# the remaining waves are taken to a separate folder called the Training_Wav_Set
# each folder has a CSV file
# the label of each WAV is read using the Sample Number -> which is also the index of the label in the label list.


import pandas as pd
import numpy as np
import librosa
import os
import librosa.display
import matplotlib.pyplot as plt
import tensorflow as tf
import tensorflow_io as tfio
import shutil
import random


def progressBar(iterable, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█', printEnd = "\r"):
    """
    Call in a loop to create terminal progress bar
    @params:
        iterable    - Required  : iterable object (Iterable)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
        printEnd    - Optional  : end character (e.g. "\r", "\r\n") (Str)
    """
    total = len(iterable)
    # Progress Bar Printing Function
    def printProgressBar (iteration):
        percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
        filledLength = int(length * iteration // total)
        bar = fill * filledLength + '-' * (length - filledLength)
        print(f'\r{prefix} |{bar}| {percent}% {suffix}', end = printEnd)
    # Initial Call
    printProgressBar(0)
    # Update Progress Bar
    for i, item in enumerate(iterable):
        yield item
        printProgressBar(i + 1)
    # Print New Line on Complete
    print()





wav_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\WAV_FORMAT\\wavs\\"
label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\WAV_FORMAT\\labels.csv"
training_label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\WAV_FORMAT\\Training_Wav_Set\\labels.csv"
testing_label_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\WAV_FORMAT\\Testing_Wav_Set\\labels.csv"

training_wav_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\WAV_FORMAT\\Training_Wav_Set\\wavs\\"
testing_wav_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\WAV_FORMAT\\Testing_Wav_Set\\wavs\\"


wav_file_names = os.listdir(wav_path)
# wav_file_names = sorted(os.listdir(wav_path), key=lambda x: int(os.path.splitext(x)[0]))

for i in range(len(wav_file_names)-1, 0, -1):
     
    # Pick a random index from 0 to i
    j = random.randint(0, i + 1)
   
    # Swap arr[i] with the element at random index
    wav_file_names[i], wav_file_names[j] = wav_file_names[j], wav_file_names[i]

Y = pd.DataFrame(columns = ['label'])
Z = pd.DataFrame(columns = ['label'])

# files = os.listdir(wav_path)

count = 0

# Loading the Labels into an array
labels = pd.read_csv(label_path)
labels.columns = ['label']
training_covid_status = labels["label"]
training_covid_status = np.asarray(training_covid_status)

# for fn in progressBar(wav_file_names, prefix = 'Converting:', suffix = '', length = 50):
#     if fn == '.DS_Store':
#         continue
#     label = fn.split('.')[0].split('_')[1]
    
#     Y = Y.append({'label':label},ignore_index=True)

# Y.to_csv(label_path,index=False)

for i in range(len(wav_file_names)):
    if(i >= 0 and i<=2142):
        label = wav_file_names[i].split('.')[0].split('_')[1]
        Y = Y.append({'label':label},ignore_index=True)
        shutil.copy(wav_path+wav_file_names[i], testing_wav_path+wav_file_names[i])
    else:
        label = wav_file_names[i].split('.')[0].split('_')[1]
        Z = Z.append({'label':label},ignore_index=True)
        shutil.copy(wav_path+wav_file_names[i], training_wav_path+wav_file_names[i])


Y.to_csv(testing_label_path,index=False)

Z.to_csv(training_label_path,index=False)











































