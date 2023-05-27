

import pandas as pd
import os
import librosa
import librosa.display
import cv2
import numpy as np
import soundfile as sf
import shutil

### Function for generatng pitch_shifted audio samples

def pitchShift():
    metaDataPath = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\meta_data.csv"
    audioDataPath = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\wavs-silence-removed\\"
    augmentedSignals = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_2_classes\\"
    metaData = pd.read_csv(metaDataPath)
    counter = 0
    for index,row in metaData.iterrows():
        fname = row["uuid"]
        print(fname, " ", str(index+1),"/",str(metaData.shape[0]))
        signal , sr = librosa.load(audioDataPath+fname+".wav")
        ## Cough detection refinment: greater than 0.7
        if row["cough_detected"] >= 0.7:
            ## Multi-class to binary classification:
            if row["status"]=="COVID-19" or row["status"] == "symptomatic":
                sf.write(augmentedSignals+"sample{0}_{1}.wav".format(counter,1), signal, sr,'PCM_24')
                counter+=1
                pitch_shifting = librosa.effects.pitch_shift(signal,sr,n_steps=-4)
                sf.write(augmentedSignals+"sample{0}_{1}.wav".format(counter,1),pitch_shifting, sr,'PCM_24')
                counter+=1
            else:
                sf.write(augmentedSignals+"sample{0}_{1}.wav".format(counter,0), signal, sr,'PCM_24')
                counter+=1    

pitchShift()

### Pitch-shift applied