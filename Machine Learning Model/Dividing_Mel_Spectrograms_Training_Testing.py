
import pandas as pd
import numpy as np
import os
import random
import shutil

mels_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\melspectrograms\\"
labels_path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\labels.csv"

training_mels = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\Split Data\\Training\\mels\\"
testing_mels = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\Split Data\\Testing\\mels\\"

training_labels = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\Split Data\\Training\\labels.csv"
testing_labels = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\Split Data\\Testing\\labels.csv"

mels_names = sorted(os.listdir(mels_path), key=lambda x: int(os.path.splitext(x)[0]))
train_mels_names = sorted(os.listdir(training_mels), key=lambda x: int(os.path.splitext(x)[0]))
test_mels_names = sorted(os.listdir(testing_mels), key=lambda x: int(os.path.splitext(x)[0]))

labels = pd.read_csv('C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\augmented-wavs-silence-removed_3_classes\\labels.csv')
labels.columns = ['label']
training_covid_status = labels["label"]
training_covid_status = np.asarray(training_covid_status)

Y = pd.DataFrame(columns = ['label'])
Z = pd.DataFrame(columns = ['label'])

# # shuffling

# print("started shuffling")

# for i in range(len(mels_names)-1, 0, -1):
     
#     # Pick a random index from 0 to i
#     j = random.randint(0, i + 1)
   
#     # Swap arr[i] with the element at random index
#     mels_names[i], mels_names[j] = mels_names[j], mels_names[i]
#     training_covid_status[i], training_covid_status[j] = training_covid_status[j], training_covid_status[i]

# print("moving data")

# for i in range(len(mels_names)):
#     if(i >= 0 and i<=5085):
#         shutil.copy(mels_path+mels_names[i], testing_mels+mels_names[i])
#         print(i)
#     else:
#         shutil.copy(mels_path+mels_names[i], training_mels+mels_names[i])
#         print(i)

for train_mel in train_mels_names:
    index = train_mel.split('.')[0]
    index = int(index)
    print(index)
    Z = Z.append({'label':training_covid_status[index]},ignore_index=True)
    
for test_mel in test_mels_names:
    index = test_mel.split('.')[0]
    index = int(index)
    print(index)
    Y = Y.append({'label':training_covid_status[index]},ignore_index=True)

Y.to_csv(testing_labels,index=False)

Z.to_csv(training_labels,index=False)