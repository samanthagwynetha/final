import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homehunt/auth/admin_auth.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  String email = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchAdminEmail();
  }

  // Fetch the admin's email from Firestore
  Future<void> _fetchAdminEmail() async {
    String adminId = 'mlGIA7f5c2SSyNMjt8FO';

    // Fetch the admin's email from Firestore
    DocumentSnapshot adminDoc =
        await _firestore.collection('Admin').doc(adminId).get();

    if (adminDoc.exists) {
      setState(() {
        email = adminDoc['email'] ?? "No email found";
      });
    } else {
      setState(() {
        email = "Admin not found in Firestore";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            "Admin Profile",
            style: TextStyle(
                fontSize: 20, fontFamily: 'Bangers', color: Colors.white),
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
                  Text(
                    "Email: $email",
                    style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'ProtestStrike',
                        color: Colors.black),
                  ),
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
                          fontSize: 20,
                          fontFamily: 'ProtestStrike',
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("L O G O U T",
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Bangers',
                        color: Colors.red)),
                onTap: () async {
                  // Since you're not using Firebase Auth for admin, adjust this if necessary
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminAuth()),
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
