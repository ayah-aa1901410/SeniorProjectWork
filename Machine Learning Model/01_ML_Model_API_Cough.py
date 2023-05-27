"""
Created on Mon Mar 13 14:24:19 2023

@author: Ayah Abdel-Ghani
"""
from flask import Flask, jsonify
from flask import request
import librosa
import librosa.display
import numpy as np
import os
import pandas as pd
import matplotlib
matplotlib.use('Agg')
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
import time
import random
import scipy
import scipy.stats



app = Flask(__name__)

app.config['TIMEOUT'] = 120

@app.route("/predict", methods=['GET','POST'])
async def predict():
    # getting the request and the files from the Mobile Application

    filess = request.files
    if 'audio.wav' not in request.files:
        return jsonify({'error': 'No file uploaded + ${filess}'})
    file = request.files['audio.wav']
    
    client_ip = request.remote_addr
    timestamp = int(time.time())
    
    filename = f'{timestamp}_{client_ip}.wav'

    # save the file to a directory of your choice

    #####################################################################################################################################################################################
    file.save(os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', filename))
    # file.save(os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', filename))
    # change to the User path on your computer
    #####################################################################################################################################################################################
    

    # checking whether the audio file contains a cough sound

    #####################################################################################################################################################################################
    model = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classifier', 'rb'))

    scaler = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classification_scaler', 'rb'))
    
    
    # model = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classifier', 'rb'))

    # scaler = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classification_scaler', 'rb'))
    # change what is before (\\Github)
    #####################################################################################################################################################################################


    #####################################################################################################################################################################################
    fs, x = wavfile.read(os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', filename))
    # fs, x = wavfile.read(os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', filename))
    # change to your User path
    #####################################################################################################################################################################################
    
    
    prob = classify_cough(x, fs, model, scaler)
    print(f"This audio recording has probability of cough: {prob}")
    if prob < 0.10:
        return jsonify({'result': "Please record your cough sound only."})

    fake = False
    if prob < 0.85:
        fake = True

    
    # segmenting the cough and removing the non-cough parts

    #####################################################################################################################################################################################
    input_file = os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', filename)
    # input_file = os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', filename)
    
    # change to your User path
    #####################################################################################################################################################################################
    
    output_name = "silence_removed_" + filename
    mel_name = output_name[:-len('.wav')]
    
    #####################################################################################################################################################################################
    output_file = os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', output_name)
    # output_file = os.path.join('C:\\Users\\Ayah Abdel-Ghani\\', output_name)
    
    # change to your User path
    #####################################################################################################################################################################################
    threshold = "-50"
    min_silence_length = "0.1"

    # subprocess.run(['unsilence', input_file, output_file, '-t', threshold, '-m', min_silence_length])


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

    # getting the processed wav file and converting it to Mel-Spectrogram
    
    #####################################################################################################################################################################################
    wave_path = "C:\\Users\\Ayah Abdel-Ghani\\" + output_name
    # wave_path = "C:\\Users\\Ayah Abdel-Ghani\\" + output_name
    
    # change to your User path
    #####################################################################################################################################################################################
    
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
    
    #####################################################################################################################################################################################
    plt.savefig(f"C:\\Users\\Ayah Abdel-Ghani\\{mel_name}.png", bbox_inches='tight')
    # plt.savefig(f"C:\\Users\\Ayah Abdel-Ghani\\{mel_name}.png", bbox_inches='tight')
    
    # change to your User path
    #####################################################################################################################################################################################
    
    plt.close('all')
    # os.environ['KMP_DUPLICATE_LIB_OK']='TRUE'

    #####################################################################################################################################################################################
    model = tf.keras.models.load_model("C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Models_KFold\\2_Classes\\Augmented_2_Classes_Model_1.hdf5")
    # model = tf.keras.models.load_model("C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Models_KFold\\2_Classes\\Augmented_2_Classes_Model_1.hdf5")
    
    # change before (\\Github)
    #####################################################################################################################################################################################

    imgArraySize = (88,39)
    
    #####################################################################################################################################################################################
    image = cv2.imread("C:\\Users\\Ayah Abdel-Ghani\\"+mel_name+".png")
    # image = cv2.imread("C:\\Users\\Ayah Abdel-Ghani\\"+mel_name+".png")
    
    # change to your User path
    #####################################################################################################################################################################################
    
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

    covPredict = np.where(score >= 0.50, 1,0)
    covPredict = str(covPredict[0][0])
    print(score)
    print(covPredict[0][0])
    
    # if score < 0.5:
    #     covPredict = 0
    # elif score > 0.5 and fake == True:
    #     covPredict = 0
    # elif score > 0.5 and fake == False:
    #     covPredict = 1
        
    # covPredict = str(covPredict)
    # print(covPredict)
    
    
    #####################################################################################################################################################################################
    os.remove("C:\\Users\\Ayah Abdel-Ghani\\"+mel_name+".png")
    os.remove("C:\\Users\\Ayah Abdel-Ghani\\"+output_name)
    os.remove("C:\\Users\\Ayah Abdel-Ghani\\"+filename)
    
    
    # os.remove("C:\\Users\\Ayah Abdel-Ghani\\"+mel_name+".png")
    # os.remove("C:\\Users\\Ayah Abdel-Ghani\\"+output_name)
    # os.remove("C:\\Users\\Ayah Abdel-Ghani\\"+filename)
    
    #change to your User path
    
    #####################################################################################################################################################################################
    return jsonify({'result': covPredict})
    # return jsonify({'result': "Hello there!"})


@app.route("/classify", methods=['GET','POST'])
async def classify():
    if request.method == 'POST':
        print('request received')
        
        body_temperature  = request.json['body_temperature']
        spo2 = request.json['spo2']
        heart_rate = request.json['heart_rate']
        
        body_temperature = float(body_temperature)
        
        print("Body Temp: " + str(request.json['body_temperature']))
        print("SPO2: " + str(request.json['spo2']))
        print("Heartrate: " + str(request.json['heart_rate']))
        
        mean = np.mean([body_temperature, heart_rate, spo2])
        minimum = np.min([body_temperature, heart_rate, spo2])
        maximum = np.max([body_temperature, heart_rate, spo2])
        rms = np.sqrt(np.mean(np.square([body_temperature, heart_rate, spo2])))
        std = np.std([body_temperature, heart_rate, spo2])
        skew = scipy.stats.skew([body_temperature, heart_rate, spo2])
        
        print("Mean: " + str(mean))
        print("Minimum: " + str(minimum))
        print("Maximum: " + str(maximum))
        print("RMS: " + str(rms))
        print("STD: " + str(std))
        print("Skew: " + str(skew))
        
        # Concatenate the extracted features
        features = np.array([mean, minimum, maximum, rms, std, skew]).reshape(1, -1)
        
        
        #################################################################################################################################
        model = load_model('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\ML model (Sp02, heart rate, stats)\\model.h5')
        # model = load_model('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\ML model (Sp02, heart rate, stats)\\model.h5')
        # change the second copy to yours (everything before \\Github)
        #################################################################################################################################
        
        classification_result = model.predict(features)
        pred_binary = np.argmax(classification_result, axis=1)
        print(classification_result)
        print(pred_binary[0])
        
        result = ""
        
        if(pred_binary == 0):
            result = "Healthy"
        else:
            result = "COVID-19"
        
        
        
        return jsonify({'result': result})

if __name__ == "__main__":
    # app.run(host="192.168.10.44",port=8000)  # home
    # app.run(host="192.168.100.105",port=8000)  # home
    # app.run(host="10.75.46.151",port=8000)
    # app.run(host="10.30.38.165",port=7000)  # uni C08
    # app.run(host="10.30.38.180",port=7000)  # uni C07
    # app.run(host="10.40.43.166",port=7000)  # uni C01
    app.run(host="10.75.46.143",port=7000)  # uni H07
    
