# -*- coding: utf-8 -*-
"""
Created on Sat Dec 10 16:43:34 2022

@author: Ayah Abdel-Ghani
"""

import pandas as pd
import librosa
import librosa.display
import soundfile as sf

### Function for separating unaugmented-cough-detected sound recordings 3_Classes

def unaugmentedCoughDetected3Classes():
    metaDataPath = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\meta_data.csv"
    audioDataPath = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\wavs-silence-removed\\"
    unaugmentedSignals = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\unaugmented-wavs-silence-removed_3_classes\\wavs\\"
    metaData = pd.read_csv(metaDataPath)
    counter = 0
    for index,row in metaData.iterrows():
        fname = row["uuid"]
        print(fname, " ", str(index+1),"/",str(metaData.shape[0]))
        signal , sr = librosa.load(audioDataPath+fname+".wav")
        ## Cough detection refinment: greater than 0.7
        if row["cough_detected"] >= 0.7:
            ## Multi-class to binary classification:
            if row["status"]=="COVID-19":
                sf.write(unaugmentedSignals+"sample{0}_{1}.wav".format(counter,2), signal, sr,'PCM_24')
                counter+=1
            elif row["status"] == "symptomatic":
                sf.write(unaugmentedSignals+"sample{0}_{1}.wav".format(counter,1), signal, sr,'PCM_24')
                counter+=1
            else:
                sf.write(unaugmentedSignals+"sample{0}_{1}.wav".format(counter,0), signal, sr,'PCM_24')
                counter+=1     
                
### Function for separating unaugmented-cough-detected sound recordings 2_Classes

def unaugmentedCoughDetected2Classes():
    metaDataPath = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\meta_data.csv"
    audioDataPath = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\wavs-silence-removed\\"
    unaugmentedSignals = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\unaugmented-wavs-silence-removed_2_classes\\wavs\\"
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
                sf.write(unaugmentedSignals+"sample{0}_{1}.wav".format(counter,1), signal, sr,'PCM_24')
                counter+=1
            else:
                sf.write(unaugmentedSignals+"sample{0}_{1}.wav".format(counter,0), signal, sr,'PCM_24')
                counter+=1   


unaugmentedCoughDetected2Classes()
