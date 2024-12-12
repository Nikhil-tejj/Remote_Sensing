import 'package:flutter/material.dart';
import 'package:remote_sensing/Pages/SARColorizerPage.dart';
import 'package:remote_sensing/Pages/cropUsingVitPage.dart';
import 'WelcomePage.dart'; // Import the WelcomePage
import 'FloodDetectionPage.dart'; // Import the FloodDetect page

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
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
    // Container(
    //         width: 100,
    //         height: 100,
    //         decoration: BoxDecoration(
    //           shape: BoxShape.circle,
    //           image: DecorationImage(
    //           image: AssetImage('assets/crop.webp'), // Replace with your logo asset path
    //           fit: BoxFit.cover,
    //           ),
    //         ),
    //         ),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomePage()),
                  );
                },
                child: const Text('Agriculture Crop Classifier'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to SAR Image Colorizer page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SARColorizerPage()),
                  );
                },
                child: const Text('SAR Image Colorizer'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to SAR Image Colorizer page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FloodDetectionPage()),
                  );
                },
                child: const Text('Flood Detection'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to SAR Image Colorizer page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CropUsingVitPage()),
                  );
                },
                child: const Text('Crop classifier using VIT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
