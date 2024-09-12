

import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'PasswordCreationPage.dart';
import 'CommonBackground.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final Future<void> Function()
      onVerified; // Callback for after OTP verification

  const EmailVerificationPage(
      {super.key, required this.email, required this.onVerified});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: CommonBackground(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'A code has been sent to ${widget.email}.',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Enter Verification Code',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      String code = _codeController.text.trim();
                      bool otpVerified = EmailOTP.verifyOTP(otp: code);

                      if (otpVerified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Email verified successfully')),
                        );

                        // Call the onVerified callback after OTP verification
                        await widget.onVerified();

                        // Navigate to Password Creation Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PasswordCreationPage(email: widget.email),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Invalid verification code')),
                        );
                      }
                    },
                    child: const Text('Verify and Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

