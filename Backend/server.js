const express = require('express');
const bodyParser = require('body-parser');
const twilio = require('twilio');
const dotenv = require('dotenv');
const cors = require('cors');
const ort = require('onnxruntime-node');
const fs = require('fs');
const path = require('path');
const { Buffer } = require('buffer');
const sharp = require('sharp');  // For image processing

// const modelPath = path.join(__dirname, 'modelSpec.onnx');
// Load environment variables from the .env file
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Twilio credentials from environment variables
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const verifyServiceSid = process.env.TWILIO_VERIFY_SERVICE_SID;

const client = twilio(accountSid, authToken);

// Enable CORS for cross-origin requests
app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));  // Adjust payload size limit for larger images

// Load ONNX model
const modelPath = path.join(__dirname, 'modelSpecNew.onnx'); // Path to ONNX model
let session;

async function loadModel() {
  try {
    session = await ort.InferenceSession.create(modelPath);
    console.log('ONNX model loaded successfully');
  } catch (error) {
    console.error('Error loading ONNX model:', error);
  }
}
loadModel();

async function preprocessImage(imageBuffer) {
  try {
    // Load the image and resize it to 224x224 pixels
    const { data, info } = await sharp(imageBuffer)
      .resize(224, 224)
      .raw()
      .toBuffer({ resolveWithObject: true });

    const { width, height, channels } = info;

    if (channels !== 3) {
      throw new Error('Image must have 3 channels (RGB)');
    }

    // Define normalization parameters (same as in PyTorch)
    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    // Create a Float32Array to hold the normalized data
    const chwData = new Float32Array(width * height * channels);

    // Rearrange and normalize the data from HWC to CHW format
    for (let c = 0; c < channels; c++) {
      for (let h = 0; h < height; h++) {
        for (let w = 0; w < width; w++) {
          const hwcIndex = h * width * channels + w * channels + c; // Index in HWC format
          const chwIndex = c * width * height + h * width + w;      // Index in CHW format

          // Normalize the pixel value
          const value = data[hwcIndex] / 255.0; // Scale to [0, 1]
          chwData[chwIndex] = (value - mean[c]) / std[c]; // Apply normalization
        }
      }
    }

    // Create the tensor with the correct shape [1, 3, 224, 224]
    const tensor = new ort.Tensor('float32', chwData, [1, 3, height, width]);

    return tensor;
  } catch (error) {
    console.error('Error preprocessing image:', error);
    throw new Error('Image preprocessing failed');
  }
}


// Inference function
async function runModel(imageTensor) {
  try {
    const feeds = { [session.inputNames[0]]: imageTensor }; // Use actual input name
    const output = await session.run(feeds);
    const outputTensor = output[session.outputNames[0]];    // Use actual output name

    // Get the predicted class index
    const scores = outputTensor.data;
    const predictedIndex = scores.indexOf(Math.max(...scores));

    const crops = ['jute', 'maize', 'rice', 'sugarcane', 'wheat'];
    return crops[predictedIndex];
  } catch (error) {
    console.error('Error running model:', error);
    throw new Error('Model inference failed');
  }
}



app.post('/predict', async (req, res) => {
  const base64Image = req.body.image;
  if (!base64Image) {
    return res.status(400).send('No image provided');
  }

  try {
    // Decode Base64 image
    const imageBuffer = Buffer.from(base64Image, 'base64');
    console.log('Image received, processing...'); // Debugging line

    // Preprocess image and run model
    const imageTensor = await preprocessImage(imageBuffer);
    const prediction = await runModel(imageTensor);

    // Return prediction
    res.status(200).send({ crop: prediction });
  } catch (error) {
    console.error('Error in /predict route:', error);
    res.status(500).send({ error: error.message });
  }
});

// Parse incoming JSON requests
app.use(bodyParser.json());

app.get('/', (req, res) => {
  res.send('Hello, World! The server is running.');
});

// Endpoint to send OTP via SMS using Twilio Verify API
app.post('/send-otp', (req, res) => {
  const { phoneNumber } = req.body;

  client.verify.v2.services(verifyServiceSid)
  .verifications.create({
    to: phoneNumber,
    channel: 'sms',
  })


    .then(verification => res.status(200).send({ sid: verification.sid }))
    .catch(error => res.status(500).send({ error: error.message }));
});


// Endpoint to verify OTP using Twilio Verify API
app.post('/verify-otp', (req, res) => {
  const { phoneNumber, otp } = req.body;

  client.verify.v2.services(verifyServiceSid)
    .verificationChecks.create({
      to: phoneNumber,
      code: otp,
    })
    .then(verificationCheck => {
      if (verificationCheck.status === 'approved') {
        res.status(200).send({ message: 'OTP verified successfully' });
      } else {
        res.status(400).send({ message: 'Invalid OTP' });
      }
    })
    .catch(error => res.status(500).send({ error: error.message }));
});

// Use HTTP for debugging
app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on http://${process.env.SERVER_IP}:${port}`);
});
