import librosa
import os
import sys
sys.path.append('./src')
from src.segmentation import segment_cough
import soundfile as sf
import argparse
from pydub import AudioSegment
import numpy as np

def main():
    input_file = "C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\detect-segment-cough\\sample_recordings\\cough.wav"
    dir_output = "C:\\Users\\Ayah Abdel-Ghani\\Documents\\"
    
    audio_file = AudioSegment.from_wav(input_file)
    
    print(f"Duration: {audio_file.duration_seconds} seconds")
    print(f"Channels: {audio_file.channels}")
    print(f"Sample rate: {audio_file.frame_rate} Hz")

    fs_out = 16000
    x, fs = librosa.load(input_file, sr=fs_out)
    cough_segments, cough_mask = segment_cough(x, fs, cough_padding=0)

    cough_only = np.concatenate(cough_segments, axis=None)

    sf.write(dir_output 
                    + os.path.basename(input_file).split('.')[0] 
                    + '.wav', 
                 cough_only, 
                 fs
        )
    print("written file")


if __name__ == '__main__':
    main()