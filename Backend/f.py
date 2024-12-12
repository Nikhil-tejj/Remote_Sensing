from flask import Flask, request, jsonify
import onnxruntime
import numpy as np
import base64
import io
from PIL import Image
import cv2

# Initialize Flask app
app = Flask(__name__)

# Load ONNX model
onnx_unetr_model_path = 'unetr.onnx'  # Update with the flood detection model path
ort_flood_detection_session = onnxruntime.InferenceSession(onnx_unetr_model_path)

def preprocess_image_for_flood_detection(image_bytes):
    """Preprocess image for flood detection model."""
    # Convert PIL Image to numpy array
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")

    # Resize image to 256x256
    image = image.resize((256, 256))
    image = np.array(image).astype(np.float32)

    # Normalize pixel values
    image = image / 255.0

    # Convert to patches manually
    patch_size = 16
    patches = []
    for i in range(0, image.shape[0], patch_size):
        for j in range(0, image.shape[1], patch_size):
            patch = image[i:i+patch_size, j:j+patch_size, :]
            patches.append(patch.flatten())
    patches = np.array(patches)
    patches = np.expand_dims(patches, axis=0)  # Add batch dimension

    return patches

# Flood detection endpoint
@app.route('/flood_detection', methods=['POST'])
def detect_flood():
    data = request.json  # Get the JSON data from the request
    image_base64 = data.get('image')  # Get the base64 image string

    if not image_base64:
        return jsonify({"error": "No image provided"}), 400

    # Decode the base64 image
    print("Image received")
    image_bytes = base64.b64decode(image_base64)

    # Preprocess the image for flood detection
    processed_image = preprocess_image_for_flood_detection(image_bytes)
    print("Image preprocessed for flood detection")

    # Run inference
    ort_inputs = {ort_flood_detection_session.get_inputs()[0].name: processed_image}
    ort_outs = ort_flood_detection_session.run(None, ort_inputs)
    print("Inference completed")

    # Postprocess the output
    prediction = np.squeeze(ort_outs[0])  # Remove batch dimension
    prediction = (prediction > 0.5).astype(np.uint8)  # Thresholding

    # Convert prediction to images
    # Predicted Mask
    predicted_mask_image = (prediction * 255).astype(np.uint8)
    predicted_mask_pil = Image.fromarray(predicted_mask_image, mode='L')  # 'L' mode for grayscale

    # Result Image with Circled Flood Areas
    result_image = np.array(Image.open(io.BytesIO(image_bytes)).convert("RGB"))
    result_image = cv2.resize(result_image, (256, 256))

    # Find contours of flood areas
    contours, _ = cv2.findContours(predicted_mask_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cv2.drawContours(result_image, contours, -1, (255, 0, 0), 4)

    result_image_pil = Image.fromarray(result_image)

    # Convert images to base64
    predicted_mask_buf = io.BytesIO()
    predicted_mask_pil.save(predicted_mask_buf, format='PNG')
    predicted_mask_base64 = base64.b64encode(predicted_mask_buf.getvalue()).decode('utf-8')

    result_image_buf = io.BytesIO()
    result_image_pil.save(result_image_buf, format='PNG')
    result_image_base64 = base64.b64encode(result_image_buf.getvalue()).decode('utf-8')

    # Return JSON with base64 encoded images
    return jsonify({
        'predicted_mask': predicted_mask_base64,
        'result_image': result_image_base64,
        'flood_detected': bool(np.max(prediction) > 0)
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3011, debug=True)