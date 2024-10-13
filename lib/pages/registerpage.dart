import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/components/button.dart';
import 'package:homehunt/components/textfield.dart';
import 'package:homehunt/helper/helperfunction.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  // Register method
  void registerUser() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Make sure passwords match
    if (passwordController.text != confirmPwController.text) {
      // Pop loading circle
      Navigator.pop(context);

      // Show error message to user
      displayMessageToUser("Error", "Passwords don't match", context);
    } else {
      // Try creating the user
      try {
        // Create user
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Create a user document and add to Firestore
        await createUserDocument(userCredential);

        // Pop loading circle
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // Pop loading circle
        Navigator.pop(context);

        // Display error message to user
        displayMessageToUser("Error", e.code, context);
      }
    }
  }

  // Create a user document and collect them in Firestore
  Future<void> createUserDocument(UserCredential userCredential) async {
    if (userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo

                Icon(
                  Icons.meeting_room_sharp,
                  size: 80,
                  color: Color.fromARGB(255, 15, 15, 15),
                ),
                // Image.asset(
                //   "images/Capture.PNG",
                //   width: MediaQuery.of(context).size.width,
                //   fit: BoxFit.fill,
                // ),
                const SizedBox(height: 20),

                // App name
                const Text(
                  "E A S E  E S T A T E",
                  style: TextStyle(fontSize: 20, fontFamily: 'Oswald') ,
                  textAlign: TextAlign.center, 
                ),

                const SizedBox(height: 50),

                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    // border: OutlineInputBorder(),
                    
                  ),
                ),
                // Username textfield

                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    // border: OutlineInputBorder(),
                
                  ),
                ),
                // Email textfield

                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    // border: OutlineInputBorder(),
                  ),
                ),
                // Password textfield

                const SizedBox(height: 20),
                TextField(
                  controller: confirmPwController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    // border: OutlineInputBorder(),
                  ),
                ),
                // Confirm password textfield

                const SizedBox(height: 25),

                // Register button
                MyButton(
                  text: "Register",
                  onTap: registerUser,
                ),
                const SizedBox(height: 25),

                // Don't have an account? Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                          color: Color.fromARGB(255, 107, 107, 107)),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        " Login Here",
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
