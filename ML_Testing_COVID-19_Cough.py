from flask import Flask, request, jsonify
import librosa
import librosa.display
import numpy as np
import os
import pandas as pd
import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow.keras import backend as K
import cv2
from tensorflow.keras.models import load_model
import pickle
from scipy.io import wavfile
import sys
sys.path.append(os.path.abspath('./src'))
sys.path.append(os.path.abspath('./src/cough_detection'))
from src.feature_class import features
from src.DSP import classify_cough
import xgboost as xgb
from pydub import AudioSegment, silence
sys.path.append('./src')
from src.segmentation import segment_cough
import soundfile as sf
import unsilence
import subprocess    


# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# checking whether the audio file contains a cough sound

model = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classifier', 'rb'))

scaler = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classification_scaler', 'rb'))

filename = "raw_4c9202a4-c44f-434b-a355-c6cf21b1b4ab.mp3"

fs, x = wavfile.read(os.path.join('C:\\Users\\Ayah Abdel-Ghani\\Desktop\\COVID-19 Audio\\', filename))
prob = classify_cough(x, fs, model, scaler)
print(f"This audio recording has probability of cough: {prob}")
if prob < 0.30:
    print("Please record your cough sound only.")
# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# segmenting the cough and removing the non-cough parts

input_file = os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', filename)
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
plt.savefig("C:\\Users\\Ayah Abdel-Ghani\\mel.png")
plt.close('all')
os.environ['KMP_DUPLICATE_LIB_OK']='TRUE'

model = tf.keras.models.load_model("C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Models_KFold\\2_Classes\\Augmented_2_Classes_Model_1.hdf5")

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
###############################################
# os.remove("C:\\Users\\Ayah Abdel-Ghani\\mel.png")
# os.remove("C:\\Users\\Ayah Abdel-Ghani\\audio.wav")
###############################################
result = np.argmax(score)
result = str(result)
print(result)