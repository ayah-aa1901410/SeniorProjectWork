# -*- coding: utf-8 -*-
"""
Created on Tue Dec  6 18:23:18 2022

@author: Ayah Abdel-Ghani
"""

import librosa
import librosa.display
import IPython.display as ipd
import matplotlib.pyplot as plt
import os
import shutil
from scipy import signal
from scipy.io import wavfile
import numpy as np
import csv

# loading the audio files with librosa

path_to_json = 'C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\wavs-silence-removed\\'
mel_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\MFCC\\MFCC_as_CSV\\"
destination_jsons = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\MFCC\\New_Python_Jsons\\"

both_destination = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\Number_Names_Separated_WAV_Jsons\\Wavs_Jsons_number_names\\"


audio_files = [pos_json for pos_json in os.listdir(path_to_json) if pos_json.endswith('.wav')]
json_files = [pos_json for pos_json in os.listdir(path_to_json) if pos_json.endswith('.json')]

RATE = 24000
N_MFCC = 13

# def get_wav(language_num):
#     '''
#     Load wav file from disk and down-samples to RATE
#     :param language_num (list): list of file names
#     :return (numpy array): Down-sampled wav file
#     '''

#     y, sr = librosa.load('./{}.wav'.format(language_num)) #Make sure to have audio file in your desktop or you may change the path as per your need
#     return(librosa.core.resample(y=y,orig_sr=sr,target_sr=RATE, scale=True))

def to_mfcc(wav, sr):
    '''
    Converts wav file to Mel Frequency Ceptral Coefficients
    :param wav (numpy array): Wav form
    :return (2d numpy array): MFCC
    '''
    return(librosa.feature.mfcc(y=wav, sr=sr, n_mfcc=N_MFCC))

# 
for n in range(len(audio_files)):
    
    # # converting to MFCCs
    # scale_file = path_to_json+audio_files[n]
    # # ipd.Audio(scale_file)
    
    # y, sr = librosa.load(scale_file)
    
    # # x = librosa.core.resample(y=y,orig_sr=sr,target_sr=RATE, scale=True)
    
    # X = to_mfcc(y, sr)
    
    # with open(mel_path+str(n+1)+".csv", 'w') as csvfile:
    #     matrixwriter = csv.writer(csvfile, delimiter=' ')
    #     for row in X:
    #         matrixwriter.writerow(row)
    
    # c = np.savetxt(mel_path+str(n+1)+".txt", X, delimiter =', ')
    name1 = audio_files[n].replace(".wav","")
    name2 = json_files[n].replace(".json","")
    if(name1 == name2):
        shutil.copy2(path_to_json+json_files[n],both_destination+str(n+1)+".json") 
        shutil.copy2(path_to_json+audio_files[n],both_destination+str(n+1)+".wav")
        print(n+1)
    
    
    # # Mel Filter Banks
    
    # filter_banks = librosa.filters.mel(n_fft=2048, sr=22050, n_mels=550)
    # filter_banks.shape
    
    # plt.figure(figsize=(25,10))
    # librosa.display.specshow(filter_banks, sr=sr, x_axis="linear")
    # plt.colorbar(format="%+2.f")
    
    # # Extracting Mel Spectrogram
    
    # mel_spectrogram = librosa.feature.melspectrogram(scale, n_fft=2048, hop_length=512, n_mels=550)
    
    # mel_spectrogram.shape
    
    # log_mel_spectrogram = librosa.power_to_db(mel_spectrogram)
    
    # plt.figure(figsize=(88,39))
    # librosa.display.specshow(log_mel_spectrogram, sr=sr)
    # # plt.colorbar(format="%+2.f")
    # shutil.copy2(path_to_json+json_files[n],destination_jsons+str(n+1)+".json") 
    # plt.savefig(mel_path+str(n+1)+".png")
    
    # # Extract MFCCs
    # mfccs = librosa.feature.mfcc(scale, n_mfcc=13, sr=sr, n_mels=550)
    
    # # visualize MFCCs
    # plt.figure(figsize=(25,10))
    # librosa.display.specshow(mfccs, x_axis="time", sr=sr)
    # plt.colorbar(format="%+2.f")
    # plt.show()
    
    # delta_mfccs = librosa.feature.delta(mfccs)
    # delta2_mfccs = librosa.feature.delta(mfccs, order=2)
    
    # plt.figure(figsize=(25,10))
    # librosa.display.specshow(delta_mfccs, x_axis="time", sr=sr)
    # plt.colorbar(format="%+2.f")
    # plt.show()
    
    # plt.figure(figsize=(25,10))
    # librosa.display.specshow(delta2_mfccs, x_axis="time", sr=sr)
    # plt.colorbar(format="%+2.f")
    # plt.show()
    
    plt.close("all")
    
    
    
#  x_axis="time", y_axis="mel",




    
