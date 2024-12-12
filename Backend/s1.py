from flask import Flask, request, jsonify, send_file
import onnxruntime as ort
from PIL import Image
import numpy as np
import io

app = Flask(__name__)

# Load the ONNX model
onnx_path = '.\pix2pix_gen.onnx'
ort_session = ort.InferenceSession(onnx_path)

def preprocess_image(image):
    # Resize and normalize the image
    image = image.resize((256, 256))
    image = np.array(image).astype(np.float32)
    image = image / 255.0  # Normalize to [0, 1]
    image = (image - 0.5) / 0.5  # Scale to [-1, 1]
    image = np.transpose(image, (2, 0, 1))  # Change to (C, H, W)
    image = np.expand_dims(image, axis=0)  # Add batch dimension
    return image

def postprocess_image(output):
    # Convert the output tensor to an image
    output = output.squeeze(0)  # Remove batch dimension
    output = np.transpose(output, (1, 2, 0))  # Change to (H, W, C)
    output = (output * 0.5 + 0.5) * 255.0  # Scale to [0, 255]
    output = output.astype(np.uint8)
    return Image.fromarray(output)

@app.route('/colorize', methods=['POST'])
def colorize():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    file = request.files['image']
    image = Image.open(file.stream).convert('RGB')
    input_tensor = preprocess_image(image)

    # Run the ONNX model
    ort_inputs = {ort_session.get_inputs()[0].name: input_tensor}
    ort_outs = ort_session.run(None, ort_inputs)
    output_image = postprocess_image(ort_outs[0])

    # Save the output image to a byte stream
    output_stream = io.BytesIO()
    output_image.save(output_stream, format='PNG')
    output_stream.seek(0)

    return send_file(output_stream, mimetype='image/png')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)