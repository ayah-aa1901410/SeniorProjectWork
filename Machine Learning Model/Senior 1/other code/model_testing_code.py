# -*- coding: utf-8 -*-
"""
Created on Thu Dec 22 21:29:38 2022

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
import pandas as pd
import os
import librosa
import librosa.display
import cv2
import numpy as np
import soundfile as sf
import shutil
from pydub import AudioSegment


def converting_to_wav():
    mp3_data_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\mp3_test_data\\"
    wav_data_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\wav_test_data\\"
    
    mp3_audio_files = [pos_json for pos_json in os.listdir(mp3_data_path) if pos_json.endswith('.mp3')]
    
    for i in range(len(mp3_audio_files)):
        try:
            if "pos" in mp3_audio_files[i]:
                sound = AudioSegment.from_mp3(mp3_data_path+mp3_audio_files[i])
                sound.export(wav_data_path+"sample{0}_{1}.wav".format(i,"pos"), format="wav")
            else:
                sound = AudioSegment.from_mp3(mp3_data_path+mp3_audio_files[i])
                sound.export(wav_data_path+"sample{0}_{1}.wav".format(i,"neg"), format="wav")
            print(i)
        except:
            print("error")
            pass
            


def pitchShifting():
    audioDataPath = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\wav_test_data\\"
    augmentedSignals = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\aug_wav_test_data\\"

    wav_audio_files = [pos_json for pos_json in os.listdir(audioDataPath) if pos_json.endswith('.wav')]

    counter = 0
    
    for i in range(len(wav_audio_files)):
        fname = wav_audio_files[i].replace(".wav", "")
        signal , sr = librosa.load(audioDataPath+fname+".wav")

        if "pos" in fname:
            sf.write(augmentedSignals+"sample{0}_{1}.wav".format(counter,1), signal, sr,'PCM_24')
            counter+=1
            # pitch_shifting = librosa.effects.pitch_shift(signal,sr,n_steps=-4)
            # sf.write(augmentedSignals+"sample{0}_{1}.wav".format(counter,1),pitch_shifting, sr,'PCM_24')
            # counter+=1
        else:
            # if i%3 == 0:
            #     pitch_shifting = librosa.effects.pitch_shift(signal,sr,n_steps=-4)
            #     sf.write(augmentedSignals+"sample{0}_{1}.wav".format(counter,0),pitch_shifting, sr,'PCM_24')
            #     counter+=1
            sf.write(augmentedSignals+"sample{0}_{1}.wav".format(counter,0), signal, sr,'PCM_24')
            counter+=1    
    

def SpectAugment(waves_path,files,param_masking,mels_path,labels_path):
    Y = pd.DataFrame(columns = ['label'])
    count = 0
    meanSignalLength = 156027
    for fn in files:
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
        if label == "pos":
            label=1
        else:
            label=0
        Y = Y.append({'label':label},ignore_index=True)
        
        # freq_mask = tfio.audio.freq_mask(dbscale_mel_spectrogram, param=param_masking)
        # time_mask = tfio.audio.time_mask(freq_mask, param=param_masking)
        # img = plt.imshow(time_mask,origin='lower')
        # plt.axis('off')
        # plt.savefig(mels_path+str(count)+".png", bbox_inches='tight')
        # plt.close('all')
        # count+=1
        # if label == "pos":
        #     label=1
        # else:
        #     label=0
        # Y = Y.append({'label':label},ignore_index=True)
    Y.to_csv(labels_path,index=False)
    
    
waves_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\aug_wav_test_data\\"    
mels_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\aug_mel_test_data\\"
labels_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\aug_labels.csv"
files = os.listdir(waves_path)


# converting_to_wav()
# pitchShifting()
SpectAugment(waves_path,files,30,mels_path,labels_path)
    
    
    