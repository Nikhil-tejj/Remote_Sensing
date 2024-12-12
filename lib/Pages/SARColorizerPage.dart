import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // For temporary file storage
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SARColorizerPage extends StatefulWidget {
  const SARColorizerPage({super.key});

  @override
  _SARColorizerPageState createState() => _SARColorizerPageState();
}

class _SARColorizerPageState extends State<SARColorizerPage> {
  File? _image;
  File? _colorizedImage;
  bool _showAssetImage = false;

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
    final serverIP = dotenv.env['SERVER_IP'];
    if (_image == null) {
      print('No image to upload'); // Debugging line
      return;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://${serverIP}:5000/colorize'));
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/colorized_image.png');
      await tempFile.writeAsBytes(bytes);

      setState(() {
        _colorizedImage = tempFile;
        _showAssetImage = true;
        print('Colorized image received'); // Debugging line
      });
    } else {
      print('Error: ${response.statusCode}'); // Debugging line
      setState(() {
        _colorizedImage = null;
        _showAssetImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAR Image Colorizer'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 145, 223, 216),
                Color.fromARGB(255, 134, 235, 201)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 127, 246, 202),
              Color.fromARGB(255, 104, 121, 117)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SAR Image Colorizer',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
                        backgroundColor:
                            const Color.fromARGB(255, 159, 217, 133),
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
                        backgroundColor:
                            const Color.fromARGB(255, 214, 242, 163),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Colorize Now'),
                    ),
              const SizedBox(height: 6),
              _colorizedImage == null
                  ? const Text(
                      'Colorized image will appear here.',
                      style: TextStyle(color: Colors.white),
                    )
                  : Column(
                      children: [
                        const Text(
                          'Generated Image',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Image.file(
                          _colorizedImage!,
                          height: 180,
                          width: 190,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ground Truth Image',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        _showAssetImage
                            ? Image.asset(
                                'assets/col.png',
                                height: 180,
                                width: 190,
                              )
                            : Container(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
