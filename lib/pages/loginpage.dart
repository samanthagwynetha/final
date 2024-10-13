import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/admin/admin_login.dart';
import 'package:homehunt/components/button.dart';
import 'package:homehunt/helper/helperfunction.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Login method
  void login() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Pop loading circle
      Navigator.pop(context);
      displayMessageToUser("Error", e.code, context);
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
              // Navigate to AdminLoginPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginPage()),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Color.fromARGB(255, 15, 15, 15), size: 30),
                // Space between icon and text
                Text(
                  "ADMIN",
                  style: TextStyle(
                      color: Color.fromARGB(255, 15, 15, 15), fontSize: 18, fontFamily: 'Bangers'),
                ),
                SizedBox(width: 16), // Space after the text
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            // Make the content scrollable
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
                  "E A S E  E S T A T E",
                  style: TextStyle(fontSize: 20, fontFamily: 'Oswald'),
                  textAlign: TextAlign.center,

                ),

                const SizedBox(height: 50),

                // Email textfield
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
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
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 25),

                // Sign in button
                MyButton(
                  text: "Login",
                  onTap: login,
                ),

                const SizedBox(height: 25),

                // Don't have an account? Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                      color: Color.fromARGB(255, 107, 107, 107),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        " Register Here",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 8, 8, 8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
