// import 'package:flutter/material.dart';
// import 'PhoneVerificationPage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   // Text editing controllers for the sign-up fields
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   // Firebase instance
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     // Get the height and width of the screen
//     final mediaQuery = MediaQuery.of(context);
//     final screenHeight = mediaQuery.size.height;
//     final screenWidth = mediaQuery.size.width;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.all(16.0),
//             constraints: BoxConstraints(
//               minHeight: screenHeight,
//             ),
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/Background.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // First name field
//                 TextField(
//                   controller: _firstNameController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'First Name',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Last name field
//                 TextField(
//                   controller: _lastNameController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Last Name',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Username field
//                 TextField(
//                   controller: _usernameController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Username',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Address field
//                 TextField(
//                   controller: _addressController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Address',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Phone number field
//                 TextField(
//                   controller: _phoneController,
//                   keyboardType: TextInputType.phone,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Phone Number',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Password field
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     labelText: 'Password',
//                     labelStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Submit button to register user
//                 ElevatedButton(
//                   onPressed: _registerUser,
//                   child: const Text('Submit'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _registerUser() async {
//     try {
//       String firstName = _firstNameController.text.trim();
//       String lastName = _lastNameController.text.trim();
//       String username = _usernameController.text.trim();
//       String phone = _phoneController.text.trim();
//       String address = _addressController.text.trim();
//       String password = _passwordController.text.trim();

//       // Firebase authentication doesn't support direct username-based sign up, so you can use email field as placeholder.
//       String fakeEmail = "$username@yourapp.com";

//       // Register user with Firebase Email and Password (using username as a placeholder email)
//       UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: fakeEmail,
//         password: password,
//       );

//       // Store additional details in Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user?.uid)
//           .set({
//         'firstName': firstName,
//         'lastName': lastName,
//         'username': username,
//         'phone': phone,
//         'address': address,
//       });

//       // Navigate to phone verification page
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const PhoneVerificationPage()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'PhoneVerificationPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Text editing controllers for the sign-up fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('http://192.168.29.241:5000/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneVerificationPage(phoneNumber: phoneNumber),
        ),
      );
    } else {
      _showErrorDialog('Failed to send OTP. Please try again.');
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
    // Get the height and width of the screen
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(
              minHeight: screenHeight,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First name field
                TextField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Last name field
                TextField(
                  controller: _lastNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Username field
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Address field
                TextField(
                  controller: _addressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone number field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Submit button to register user
                ElevatedButton(
                  onPressed: () {
                    sendOtp(_phoneController.text);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
