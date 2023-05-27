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
    
    
wave_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\wavs\\sample3_0.wav"
meanSignalLength = 156027
signal , sr = librosa.load(wave_path)
s_len = len(signal)
if s_len < meanSignalLength:
       pad_len = meanSignalLength - s_len
       pad_rem = pad_len % 2
       pad_len //= 2
       signal = np.pad(signal, (pad_len, pad_len + pad_rem), 'constant', constant_values=0)
else:
       pad_len = s_len - meanSignalLength
       pad_len //= 2
       signal = signal[pad_len:pad_len + meanSignalLength]



plt.figure(figsize=(14, 5)) 
librosa.display.waveshow(signal, sr=sr)

mel_spectrogram = librosa.feature.melspectrogram(y=signal,sr=sr,n_mels=128,hop_length=512,fmax=8000,n_fft=512,center=True)
dbscale_mel_spectrogram = librosa.power_to_db(mel_spectrogram, ref=np.max,top_db=80)
img = plt.imshow(dbscale_mel_spectrogram, interpolation='nearest',origin='lower')
plt.savefig("C:\\Users\\Ayah Abdel-Ghani\\mel_correct.png")