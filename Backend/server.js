const express = require('express');
const bodyParser = require('body-parser');
const twilio = require('twilio');
const dotenv = require('dotenv');
const cors = require('cors');

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

// app.post('/send-otp', (req, res) => {
//   const { phoneNumber, otp } = req.body;

//   const message = `Your verification code is: ${otp}. Please use this to verify your account.`;

//   client.messages
//     .create({
//       body: message,
//       from: twilioPhoneNumber, // Twilio phone number from which the SMS will be sent
//       to: phoneNumber,
//     })
//     .then(message => {
//       res.status(200).send({ sid: message.sid, message: 'OTP sent successfully' });
//     })
//     .catch(error => {
//       res.status(500).send({ error: error.message });
//     });
// });

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
