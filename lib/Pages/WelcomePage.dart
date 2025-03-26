import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  File? _image;
  String? _prediction;
  // String? _serverIp;

  @override
  void initState() {
    super.initState();
    // Load the environment variables
    // _loadEnv();
  }

  // Future<void> _loadEnv() async {
  //   await dotenv.load(); // Load the environment variables
  //   setState(() {
  //     _serverIp = dotenv.env['SERVER_IP']; // Get the SERVER_IP
  //     print('Server IP loaded: $_serverIp'); // Debugging line
  //   });
  // }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          print('Image selected: ${_image!.path}'); // Debugging line
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadImage() async {
    final serverIp = dotenv.env['SERVER_IP'];
    final port = dotenv.env['PORT'];
    if (_image == null) {
      print('No image to upload'); // Debugging line
      return;
    }

    // Convert image to Base64
    String base64Image = base64Encode(_image!.readAsBytesSync());
    print(
        'Base64 image size: ${base64Image.length} characters'); // Debugging line

    // Prepare the request payload
    var response = await http.post(
      Uri.parse('http://$serverIp:$port/predict'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image': base64Image,
      }),
    );

    // Handle the response
    print('Response status: ${response.statusCode}'); // Debugging line
    if (response.statusCode == 200) {
      var resBody = json.decode(response.body);
      setState(() {
        _prediction = resBody['crop'];
        print('Prediction received: $_prediction'); // Debugging line
      });
    } else {
      print('Error: ${response.body}'); // Debugging line
      setState(() {
        _prediction = 'Error: Could not predict the crop.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Classifier'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 145, 223, 216), Color.fromARGB(255, 134, 235, 201)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 127, 246, 202), Color.fromARGB(255, 104, 121, 117)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
              'Agriculture Crop Classifier',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              ),
              const SizedBox(height: 16),
              // Add a logo or placeholder image
              // Container(
              // width: 100,
              // height: 100,
              // decoration: BoxDecoration(
              //   shape: BoxShape.circle,
              //   image: DecorationImage(
              //   image: AssetImage('assets/crop.webp'), // Replace with your logo asset path
              //   fit: BoxFit.cover,
              //   ),
              // ),
              // ),
              const SizedBox(height: 16),
              _image == null
                ? const Text(
                  '',
                  style: TextStyle(color: Colors.white),
                )
                : Image.file(
                  _image!,
                  height: 200,
                  width: 200,
                ),
              const SizedBox(height: 16),
              _image == null
                ? ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: const Color.fromARGB(255, 159, 217, 133),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  ),
                      child: const Text('Select Image'),
                    )
                  : ElevatedButton(
                      onPressed: _uploadImage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: const Color.fromARGB(255, 214, 242, 163),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Predict Now'),
                    ),
              const SizedBox(height: 16),
              _prediction == null
                  ? const Text(
                      'Prediction will appear here.',
                      style: TextStyle(color: Colors.white),
                    )
                  : Text(
                      'Predicted crop: $_prediction',
                      // 'Predicted crop: Rice',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
