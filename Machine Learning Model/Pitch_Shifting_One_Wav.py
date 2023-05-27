# -*- coding: utf-8 -*-
"""
Created on Tue Dec 27 20:15:11 2022

@author: Ayah Abdel-Ghani
"""

import pandas as pd
import os
import librosa
import librosa.display
import cv2
import numpy as np
import soundfile as sf
import matplotlib.pyplot as plt
import tensorflow as tf
import tensorflow_io as tfio

wave_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\wavs\\sample1_0.wav"
meanSignalLength = 156027
signal , sr = librosa.load(wave_path)
s_len = len(signal)

#### plotting original signal

# plt.figure(figsize=(14, 5)) 
# librosa.display.waveshow(signal, sr=sr)

#### plotting shifted signal

# plt.figure(figsize=(14, 5)) 
pitch_shifting = librosa.effects.pitch_shift(signal,sr,n_steps=-4)
# librosa.display.waveshow(pitch_shifting, sr=sr)

if s_len < meanSignalLength:
       pad_len = meanSignalLength - s_len
       pad_rem = pad_len % 2
       pad_len //= 2
       signal = np.pad(signal, (pad_len, pad_len + pad_rem), 'constant', constant_values=0)
else:
       pad_len = s_len - meanSignalLength
       pad_len //= 2
       signal = signal[pad_len:pad_len + meanSignalLength]

#### creating mel-spectrogram and plotting it

mel_spectrogram = librosa.feature.melspectrogram(y=signal,sr=sr,n_mels=128,hop_length=512,fmax=8000,n_fft=512,center=True)
dbscale_mel_spectrogram = librosa.power_to_db(mel_spectrogram, ref=np.max,top_db=80)
img = plt.imshow(dbscale_mel_spectrogram, interpolation='nearest',origin='lower')