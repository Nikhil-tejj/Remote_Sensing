
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CropUsingVitPage extends StatefulWidget {
  const CropUsingVitPage({super.key});

  @override
  State<CropUsingVitPage> createState() => _CropUsingVitPageState();
}

class _CropUsingVitPageState extends State<CropUsingVitPage> {
  File? _image; // Variable to hold the picked image
  String? _prediction; // To hold the prediction result
  bool _imageSelected = false; // Flag to track if an image is selected

  // Pick Image from the gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path); // Update _image state
          _imageSelected = true; // Set flag to true
        });
        print('Image selected: ${_image!.path}'); // Debugging line
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Upload Image to the server for prediction
  Future<void> _uploadImage() async {
    final serverIp = dotenv.env['SERVER_IP'];
    final port = dotenv.env['PORT'];
    if (_image == null) {
      print('No image to upload');
      return;
    }

    if (serverIp == null || port == null) {
      print('Server IP or port is not set in the environment variables.');
      return;
    }

    String base64Image = base64Encode(_image!.readAsBytesSync());
    try {
      print('Uploading image: ${_image!.path}'); // Debugging line
      var response = await http.post(
        Uri.parse('http://$serverIp:$port/predictvit'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Image,
        }),
      );

      print('Response status: ${response.statusCode}'); // Debugging line
      print('Response body: ${response.body}'); // Debugging line

      if (response.statusCode == 200) {
        var resBody = json.decode(response.body);
        setState(() {
          _prediction = resBody['crop'];
        });
      } else {
        setState(() {
          _prediction = 'Error: Could not predict the crop.';
        });
      }
    } catch (e) {
      print('Error uploading image: $e'); // Debugging line
      setState(() {
        _prediction = 'Error uploading image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ViT Crop Classification'),
        backgroundColor: const Color.fromARGB(255, 108, 243, 191),
      ),
      body: Stack(
        children: [
          // Background with overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/col.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.6), // Overlay for better readability
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Crop Classification using ViT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (!_imageSelected) // Conditionally render the button
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Select Image from Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 166, 253, 170),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _uploadImage,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Upload and Predict'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 160, 206, 246),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _prediction == null
                      ? const Text(
                          'Prediction will appear here.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            'Predicted Crop: $_prediction',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}