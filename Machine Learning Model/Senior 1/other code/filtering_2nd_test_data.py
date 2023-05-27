# -*- coding: utf-8 -*-
"""
Created on Thu Dec 22 23:20:06 2022

@author: Ayah Abdel-Ghani
"""

import shutil
import json
import numpy as np
import os

f = open('C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\dataset\\metadata.json')

data = json.load(f)

posCount = 0
negCount = 0
sympCount = 0
otherCount = 0

posFilenames = []
negFilenames = []
sympFilenames = []

class MyObject:
    def __init__(self, d=None):
        if d is not None:
            for key, value in d.items():
                setattr(self, key, value)

for i in range(len(data)):
    obj = MyObject(data[i])
    print(data[i].get('verified'))
    if (data[i].get('verified') == True and data[i].get('covid19') == True):
        posFilenames.append(data[i].get('filename'))
        posCount = posCount+1
    elif (data[i].get('covid19') == False):
        negFilenames.append(data[i].get('filename'))
        negCount = negCount+1
    # elif (data[i].get('verified') == False and data[i].get('covid19') == True and data[i].get('asymptomatic') == False):
    #     posFilenames.append(data[i].get('filename'))
    #     sympCount = sympCount+1
    # else:
    #     otherCount = otherCount+1
    
print(posCount)
print(negCount)
# print(sympCount)
# print(otherCount)

mp3FilesPath = "C:\\Users\\Ayah Abdel-Ghani\\Documents\\GitHub\\dataset\\raw\\"
destination = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\2nd_testing_data\\mp3_test_data\\"

mp3_audio_files = [pos_json for pos_json in os.listdir(mp3FilesPath) if pos_json.endswith('.mp3')]

posCount = 0
negCount = 0
#  positive
for i in range(len(posFilenames)):
    if posFilenames[i] in mp3_audio_files:
        # print('yes')
        posCount = posCount+1
        shutil.copy2 (mp3FilesPath+posFilenames[i], destination+"pos_"+posFilenames[i])
    

for i in range(len(negFilenames)):
    if negFilenames[i] in mp3_audio_files:
        print('yes')
        negCount = negCount+1
        shutil.copy2 (mp3FilesPath+negFilenames[i], destination+"neg_"+negFilenames[i])

print(posCount)
print(negCount)

# for i in range(len(sympFilenames)):
#     if sympFilenames[i] in mp3_audio_files:
#         shutil.copy2 (mp3FilesPath+sympFilenames[i], destination+"symp_"+sympFilenames[i])








# for i in range(len(data)):
#     print(type(data[i]))
#     if (data[i].verified == True and data[i].covid19 == True):
#         posCount = posCount+1
#     elif (data[i].verified == False and data[i].covid19 == False and data[i].asymptomatic == True):
#         negCount = negCount+1
#     elif (data[i].verified == False and data[i].covid19 == True and data[i].asymptomatic == False):
#         sympCount = sympCount+1
#     else:
#         otherCount = otherCount+1