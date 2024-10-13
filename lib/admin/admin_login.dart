import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/admin/admin_navbar.dart';
import 'package:homehunt/auth/auth.dart';
import 'package:homehunt/components/button.dart';
import 'package:homehunt/components/textfield.dart';
import 'package:homehunt/helper/helperfunction.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Admin login method using Firestore
  void adminLogin() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Fetch admin data from Firestore by matching the email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Admin')
            .where('email', isEqualTo: emailController.text.trim())
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var adminDoc = querySnapshot.docs.first;
          var storedPassword = adminDoc['password'];

          // Check if the entered password matches the stored password
          if (passwordController.text.trim() == storedPassword) {
            // Password matches, navigate to admin dashboard
            Navigator.pop(context); // Close loading indicator
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminNavbar()),
            );
          } else {
            // Password is incorrect
            Navigator.pop(context);
            displayMessageToUser(
              "Error",
              "Incorrect password. Please try again.",
              context,
            );
          }
        } else {
          // No admin with this email found
          Navigator.pop(context);
          displayMessageToUser(
            "Error",
            "No admin found with this email.",
            context,
          );
        }
      } catch (e) {
        // Print the actual error for debugging
        print("Error: $e");
        Navigator.pop(context);
        displayMessageToUser(
          "Error",
          "An error occurred. Please try again.\nError: $e", // Show actual error
          context,
        );
      }
    }
  }

  bool _obscureText = true;
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              // Navigate to Customer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.person_rounded,
                    color: Color.fromARGB(255, 15, 15, 15),), // Space between icon and text
                Text(
                  "USER",
                  style: TextStyle(
                     color: Color.fromARGB(255, 15, 15, 15), fontSize: 18, fontFamily: 'Bangers'),
                ),
                SizedBox(width: 16), // Space after the text
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFededeb),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            // Make the content scrollable
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Icon(
                    Icons.meeting_room_sharp,
                    size: 80,
                    color: Color.fromARGB(255, 15, 15, 15),
                  ),
                    const SizedBox(height: 25),

                  // App name
                  const Text(
                    "E A S E E S T A T E",
                    style: TextStyle(fontSize: 20, fontFamily: 'Oswald'),
                  ),
                  const SizedBox(height: 50),

                  // Email text field
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Admin email',
                      // border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password textfield
                  TextField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      // border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign in button
                  MyButton(
                    text: "LOGIN",
                    onTap: adminLogin,
                  ),
                     const SizedBox(height: 20),

                  // Admin only
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "This login page is for admin",
                        style: TextStyle(color: Color.fromARGB(255, 107, 107, 107)),
                      ),
                    ],
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
