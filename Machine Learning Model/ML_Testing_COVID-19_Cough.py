import os
import pickle
import sys

import cv2
import librosa
import librosa.display
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import tensorflow as tf
from flask import Flask, jsonify, request
from scipy.io import wavfile
from tensorflow.keras import backend as K
from tensorflow.keras.models import load_model

sys.path.append(os.path.abspath('./src'))
sys.path.append(os.path.abspath('./src/cough_detection'))
import xgboost as xgb
from pydub import AudioSegment, silence

from src.DSP import classify_cough
from src.feature_class import features

sys.path.append('./src')
import subprocess

import soundfile as sf
import unsilence

from src.segmentation import segment_cough

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# checking whether the audio file contains a cough sound

model = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classifier', 'rb'))

scaler = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classification_scaler', 'rb'))

filename = "ayah_fake_cough_6.wav"


fs, x = wavfile.read(os.path.join('C:\\Users\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\wavs\\', filename))
prob = classify_cough(x, fs, model, scaler)
print(f"This audio recording has probability of cough: {prob}")
if prob < 0.10:
    print("Please record your cough sound only.")
# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# segmenting the cough and removing the non-cough parts

input_file = os.path.join('C:\\Users\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\WAV_FORMAT\\Testing_Wav_Set\\wavs\\', filename)
output_name = "audio_silence_removed.wav"
output_file = os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', output_name)
threshold = "-50"
min_silence_length = "0.1"


# Load the audio file
audio_file = AudioSegment.from_wav(input_file)

# Define the silence threshold in dB
silence_thresh = -50

# Split the audio file into non-silent chunks
nonsilent_chunks = silence.split_on_silence(audio_file, 
                                            min_silence_len=500, 
                                            silence_thresh=silence_thresh)

# Concatenate the non-silent chunks into one audio file
output_audio = AudioSegment.empty()
for chunk in nonsilent_chunks:
    output_audio += chunk

# Export the output audio file
output_audio.export(output_file, format="wav")

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# getting the processed wav file and converting it to Mel-Spectrogram
wave_path = "C:\\Users\\Ayah Abdel-Ghani\\" + output_name
meanSignalLength = 156027
signal , sr = librosa.load(wave_path)
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

mel_spectrogram = librosa.feature.melspectrogram(y=signal,sr=sr,n_mels=128,hop_length=512,fmax=8000,n_fft=512,center=True)
dbscale_mel_spectrogram = librosa.power_to_db(mel_spectrogram, ref=np.max,top_db=80)
img = plt.imshow(dbscale_mel_spectrogram, interpolation='nearest',origin='lower')
plt.axis('off')
plt.savefig("C:\\Users\\Ayah Abdel-Ghani\\mel.png", bbox_inches='tight')
plt.close('all')
# os.environ['KMP_DUPLICATE_LIB_OK']='TRUE'

model = tf.keras.models.load_model("C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Models_KFold\\2_Classes\\Augmented_2_Classes_Model_2nd_Trial_01.hdf5")


imgArraySize = (88,39)
image = cv2.imread("C:\\Users\\Ayah Abdel-Ghani\\mel.png")
image = cv2.resize(image,imgArraySize)
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
image = np.asarray(image,dtype=np.float32)
image = image/225.0

rows = imgArraySize[1]
cols = imgArraySize[0]

if K.image_data_format() == 'channels_first':
    image = image.reshape(1,3,rows,cols)
else:
    image = image.reshape(1,rows,cols,3)

score = model.predict(image)
##############################################
# os.remove("C:\\Users\\Ayah Abdel-Ghani\\mel.png")
# os.remove("C:\\Users\\Ayah Abdel-Ghani\\audio.wav")
###############################################
covPredict = np.where(score >= 0.5, 1,0)
# result = np.argmax(score)
# result = str(result)
print(score)
print(covPredict[0][0])