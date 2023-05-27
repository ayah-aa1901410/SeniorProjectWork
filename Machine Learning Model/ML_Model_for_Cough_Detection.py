import os
import sys
sys.path.append(os.path.abspath('./src'))
sys.path.append(os.path.abspath('./src/cough_detection'))
from src.feature_class import features
from src.DSP import classify_cough
from scipy.io import wavfile
import pickle
import argparse
import librosa
import xgboost as xgb
from pydub import AudioSegment, silence


def main():

    model = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classifier', 'rb'))

    scaler = pickle.load(open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\sdp2223-50-f\\Machine Learning Model\\Cough_Classifier Model\\cough_classification_scaler', 'rb'))

    # fs, x = librosa.load("C:\\no_cough.m4a") 
    # fs, x = wavfile.read("C:\\cough.wav")
    fs, x = wavfile.read("C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\detect-segment-cough\\sample_recordings\\artif-cough.wav")
    prob = classify_cough(x, fs, model, scaler)
    print(f"This audio recording has probability of cough: {prob}")

    return prob

if __name__ == '__main__':
    main()