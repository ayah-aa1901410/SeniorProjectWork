from flask import Flask, request, jsonify
import random
from tensorflow.keras.models import load_model
import numpy as np
import scipy

app = Flask(__name__)

@app.route('/classify', methods=['POST'])
async def classify():
    if request.method == 'POST':
        body_temperature = int(request.json['body_temperature'])
        spo2 = int(request.json['spo2'])
        heart_rate = int(request.json['heart_rate'])
        
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
    # app.run(host="192.168.10.8", port=7000)
    # app.run(host="192.168.10.44", port=7000)
    ######################################################################################################################################
    app.run(host="192.168.10.44", port=7000)
    # change the above IP-Address to yours
    ######################################################################################################################################