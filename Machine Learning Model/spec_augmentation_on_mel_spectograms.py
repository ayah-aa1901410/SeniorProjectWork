# -*- coding: utf-8 -*-
"""
Created on Sat Dec 10 14:24:39 2022

@author: Ayah Abdel-Ghani
"""
import pandas as pd
import numpy as np
import librosa
import os
import librosa.display
import matplotlib.pyplot as plt
import tensorflow as tf
import tensorflow_io as tfio

## Function for showing a progress bar

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

def SpectAugment(waves_path,files,param_masking,mels_path,labels_path):
    Y = pd.DataFrame(columns = ['label'])
    count = 0
    meanSignalLength = 156027
    for fn in progressBar(files, prefix = 'Converting:', suffix = '', length = 50):
        if fn == '.DS_Store':
            continue
        label = fn.split('.')[0].split('_')[1]
        signal , sr = librosa.load(waves_path+fn)
        s_len = len(signal)
        ## Add zero padding to the signal if less than 156027 (~4.07 seconds) / Remove from begining and the end if signal length is greater than 156027 (~4.07 seconds)
        if s_len < meanSignalLength:
               pad_len = meanSignalLength - s_len
               pad_rem = pad_len % 2
               pad_len //= 2
               signal = np.pad(signal, (pad_len, pad_len + pad_rem), 'constant', constant_values=0)
        else:
               pad_len = s_len - meanSignalLength
               pad_len //= 2
               signal = signal[pad_len:pad_len + meanSignalLength]
        label = fn.split('.')[0].split('_')[1]
        mel_spectrogram = librosa.feature.melspectrogram(y=signal,sr=sr,n_mels=128,hop_length=512,fmax=8000,n_fft=512,center=True)
        dbscale_mel_spectrogram = librosa.power_to_db(mel_spectrogram, ref=np.max,top_db=80)
        img = plt.imshow(dbscale_mel_spectrogram, interpolation='nearest',origin='lower')
        plt.axis('off')
        plt.savefig(mels_path+str(count)+".png", bbox_inches='tight')
        plt.close('all')
        count+=1
        Y = Y.append({'label':label},ignore_index=True)
        if label == '1': # if COVID-19
            freq_mask = tfio.audio.freq_mask(dbscale_mel_spectrogram, param=param_masking)
            time_mask = tfio.audio.time_mask(freq_mask, param=param_masking)
            img = plt.imshow(time_mask,origin='lower')
            plt.axis('off')
            plt.savefig(mels_path+str(count)+".png", bbox_inches='tight')
            plt.close('all')
            count+=1
            Y = Y.append({'label':label},ignore_index=True) 
        freq_mask = tfio.audio.freq_mask(dbscale_mel_spectrogram, param=param_masking)
        time_mask = tfio.audio.time_mask(freq_mask, param=param_masking)
        img = plt.imshow(time_mask,origin='lower')
        plt.axis('off')
        plt.savefig(mels_path+str(count)+".png", bbox_inches='tight')
        plt.close('all')
        count+=1
        Y = Y.append({'label':label},ignore_index=True)
    Y.to_csv(labels_path,index=False)
    
    
waves_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\wavs\\"
mels_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\melspectrograms\\"
labels_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\labels.csv"
files = os.listdir(waves_path)
SpectAugment(waves_path,files,30,mels_path,labels_path)
