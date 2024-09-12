// import 'package:flutter/material.dart';
// import 'EmailInputPage.dart';
// import 'CommonBackground.dart';

// class PhoneVerificationPage extends StatefulWidget {
//   const PhoneVerificationPage({super.key});

//   @override
//   State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
// }

// class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
//   final TextEditingController _otpController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Phone Number Verification'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: CommonBackground(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 16), // Adds space from top

//                   // Text for OTP instruction
//                   const Text(
//                     'Please enter the OTP sent to the number you just entered.',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16), // Space between text and input

//                   // TextField for OTP input
//                   TextField(
//                     controller: _otpController,
//                     keyboardType: TextInputType.number,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: const InputDecoration(
//                       labelText: 'Enter OTP',
//                       labelStyle: TextStyle(color: Colors.white),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.white),
//                       ),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Verify and Next button
//                   ElevatedButton(
//                     onPressed: () {
//                       String otp = _otpController.text;
//                       // Do something with the entered OTP
//                       print('Entered OTP: $otp');

//                       // Navigate to the EmailInputPage
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const EmailInputPage(),
//                         ),
//                       );
//                     },
//                     child: const Text('Verify & Next'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'EmailInputPage.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerificationPage({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final TextEditingController _otpController =
      TextEditingController(); // OTP input field controller

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    final response = await http.post(
      Uri.parse('http://192.168.29.241:5000/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailInputPage(),
        ),
      );
    } else {
      _showErrorDialog('Failed to verify OTP. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // OTP input field
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Button to verify OTP
            ElevatedButton(
              onPressed: () {
                verifyOtp(widget.phoneNumber, _otpController.text);
              },
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
