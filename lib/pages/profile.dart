import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homehunt/auth/auth.dart';
import 'package:homehunt/widget/support_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String email = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "No email found";
      });
    }
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Delete user from Firebase Authentication
        await user.delete();

        // Optionally, delete user data from Firestore
        await _firestore.collection('Users').doc(user.uid).delete();

        // Log out the user
        await _auth.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account deleted successfully.")));
        Navigator.of(context).pop(); // Navigate back to the previous screen
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account: $e")));
    }
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "User Profile",
            style: TextStyle(
                fontSize: 18, fontFamily: 'Bangers', color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display Email
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.black),
                  const SizedBox(width: 10.0),
                  Text("Email: $email",
                      style: const TextStyle(
                          fontSize: 18.0, fontFamily: 'ProtestStrike')),
                ],
              ),
            ),

            // Terms and Conditions
            GestureDetector(
              onTap: () {
                // Navigate to terms and conditions page
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.description, color: Colors.black),
                    SizedBox(width: 10.0),
                    Text(
                      "Terms and Conditions",
                      style: TextStyle(
                          fontSize: 18.0, fontFamily: 'ProtestStrike'),
                    ),
                  ],
                ),
              ),
            ),

            // Delete Account
            GestureDetector(
              onTap: _deleteAccount,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 10.0),
                    Text(
                      "Delete Account",
                      style: TextStyle(
                          fontSize: 18.0, fontFamily: 'ProtestStrike'),
                    ),
                  ],
                ),
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 25),
              child: ListTile(
                leading: Icon(Icons.logout,
                    color: const Color.fromARGB(255, 172, 158, 40)),
                title: const Text(
                  "L O G O U T",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Bangers',
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
