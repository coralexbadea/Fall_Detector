import torch
import torch.nn as nn
from flask import Flask, jsonify, request
from model import GRUNet
import numpy as np 

# Load the TensorFlow model
input_dim = 3
output_dim = 2
n_layers = 2
hidden_dim = 256

model = GRUNet(input_dim, hidden_dim, output_dim, n_layers)
model.load_state_dict(torch.load('SmartFall_gru.pth',map_location=torch.device('cpu')))

# Initialize the Flask app
app = Flask(__name__)

# Define the route for making predictions
@app.route('/predict', methods=['POST'])
def predict():
    # Get the input data from the request
    data = request.json
    print("HRER!!", request.get_json())
    # Convert the input data to a format that can be used by the model
    test_input = torch.Tensor([data['x'],data['y'],data['z']]).repeat(40,1).unsqueeze(0)

    # Make a prediction using the model
    output = model(test_input)

    # Convert the prediction to a format that can be returned in the response
    output_data = torch.argmax(output).item()
    print("alright!", output_data)
    # Return the prediction as a JSON response
    return jsonify(output_data)

if __name__ == '__main__':
    app.run(debug=True,host="0.0.0.0")
