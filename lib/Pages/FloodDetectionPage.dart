import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class FloodDetectionPage extends StatefulWidget {
  @override
  _FloodDetectionPageState createState() => _FloodDetectionPageState();
}

class _FloodDetectionPageState extends State<FloodDetectionPage> {
  Uint8List? _pickedImage;
  Uint8List? _resultImage;
  Uint8List? _predictedMask;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    setState(() {
      _pickedImage = bytes;
      _detectFlood();
    });
  }

  Future<void> _detectFlood() async {
    final serverIp = dotenv.env['SERVER_IP'];
    final port = dotenv.env['PORT'];
    if (_pickedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    final base64Image = base64Encode(_pickedImage!);

    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:$port/flood'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictedMask = base64Decode(data['predicted_mask']);
          _resultImage = base64Decode(data['result_image']);
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Failed to connect to server: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flood Detection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_pickedImage == null) ...[
              Icon(
                Icons.water_damage,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
            ],
            SizedBox(height: 20),
            if (_pickedImage != null) ...[
              Text(
                'Grayscale Image:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Center(child: Image.memory(_pickedImage!, height: 150)),
            ],
            SizedBox(height: 20),
            if (_resultImage != null) ...[
              Text(
                'Result Image:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Center(child: Image.memory(_resultImage!, height: 150)),
            ],
            SizedBox(height: 20),
            if (_predictedMask != null) ...[
              Text(
                'Masked Image:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Center(child: Image.memory(_predictedMask!, height: 150)),
            ],
            if (_isLoading)
              Column(
                children: [
                  SizedBox(height: 30),
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Processing, please wait...'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
