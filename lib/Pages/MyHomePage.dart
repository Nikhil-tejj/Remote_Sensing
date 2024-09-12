import 'package:flutter/material.dart';
import 'Sign_up_Page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Text editing controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: mediaQuery.size.height, // Makes it fill the available space
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Background.jpg'),
              fit: BoxFit.cover, // Better suited for full background images
            ),
          ),
          padding:
              const EdgeInsets.all(16.0), // You can adjust the padding here
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextField for email (username)
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                  // Label text color
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Border color when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Border color when focused
                  ),
                ),
                style: const TextStyle(color: Colors.white), // Text input color
              ),

              const SizedBox(height: 16), // Space between fields

              // TextField for password
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                // Set text color to white
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  // Set label color to white
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Set border color to white
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .white), // Set border color to white when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .white), // Set border color to white when enabled
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .white), // Set border color to white when disabled
                  ),
                ),
                cursorColor: Colors.white, // Set cursor color to white
              ),
              const SizedBox(
                  height: 16), // Space between the password field and button

              ElevatedButton(
                onPressed: () {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  // Do something with the entered email and password
                  print('Email: $email, Password: $password');
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 8),

              // Text button for sign up with underlined text
              TextButton(
                onPressed: () {
                  // Navigate to the SignUpPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'New User ? Click on ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 18.0, // Increase the font size here
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: Color.fromARGB(
                              255, 255, 255, 255), // Color for the link
                          decoration: TextDecoration
                              .underline, // Underline the 'Sign Up' text
                          fontSize: 18.0, // Increase the font size here
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
