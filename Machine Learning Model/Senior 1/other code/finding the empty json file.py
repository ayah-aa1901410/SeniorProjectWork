import os
import json
import shutil

path = "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\jsons\\"

json_files = [pos_json for pos_json in os.listdir(path) if pos_json.endswith('.json')]

for n in range(len(json_files)):
    if n == 9956:
        shutil.copy2(path+json_files[n], "C:\\Users\\Ayah Abdel-Ghani\\Desktop\\Coughing Dataset\\researchersilenceremoveddataset\\coughvid-clean-silence-removed\\new_jsons_names\\"+json_files[n])