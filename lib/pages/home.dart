import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/pages/details.dart';
import 'package:homehunt/services/database.dart';
import 'package:homehunt/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> bookingStream;
  Stream? roomItemStream;
  String selectedCategory = "Standard";

  @override
  void initState() {
    super.initState();
    onLoad();
    fetchNAME();
  }

  String? username;
  String? nameks;

  void fetchNAME() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      username = user.email;
      namek(username.toString());
    } else {
      username = 'Guest'; // or any default value you prefer
    }
  }

  namek(String email) async {
    CollectionReference usersk = FirebaseFirestore.instance.collection('Users');
    DocumentSnapshot snapshot = await usersk.doc(email).get();
    nameks = snapshot['username'];
  }

  onLoad() async {
    roomItemStream = await DatabaseMethods().getRoomItem(selectedCategory);
    setState(() {});
  }

  Widget allItemsVertically() {
    return StreamBuilder(
      stream: roomItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const Center(child: Text("No items found."));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Details(
                      title: ds["Title"],
                      description: ds["Description"],
                      address: ds["Address"],
                      price: ds["Price"],
                      maxguests: ds["MaxGuests"],
                      images: ds["Image"],
                      status: ds["Status"],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10.0, bottom: 15),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          ds["Image"],
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ds["Title"],
                                  style: const TextStyle(
                                      fontFamily: 'Oswald', fontSize: 20, fontWeight: FontWeight.bold)), 
                              const SizedBox(height: 10),
                              Text("Maxguest:${ds["MaxGuests"]}",
                                  style: const TextStyle(
                                      fontFamily: 'Oswald', fontSize: 18)),
                              const SizedBox(height: 3),
                              Text("${ds["Status"]}",
                                  style: const TextStyle(
                                      fontFamily: 'Oswald', fontSize: 18)),
                              const SizedBox(height: 3),
                              Text("₱${ds["Price"]}",
                                  style: const TextStyle(
                                      fontFamily: 'Oswald', fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget allItems() {
    return StreamBuilder(
      stream: roomItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const Center(
              child: Text(
            "No items found.",
            style: TextStyle(fontFamily: 'Oswald', fontSize: 20),
          ));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Details(
                      title: ds["Title"],
                      description: ds["Description"],
                      address: ds["Address"],
                      price: ds["Price"],
                      maxguests: ds["MaxGuests"],
                      images: ds["Image"],
                      status: ds["Status"],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            ds["Image"],
                            height: 130,
                            width: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(ds["Title"],
                            style: const TextStyle(
                                fontFamily: 'Oswald', fontSize: 20)),
                        Text("₱${ds["Price"]} /Day",
                            style: const TextStyle(
                                fontFamily: 'Oswald', fontSize: 20)),
                        Text("Maxguest:${ds["MaxGuests"]}",
                            style: const TextStyle(
                                fontFamily: 'Oswald', fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
          onLoad();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedCategory == category ? Colors.black : Colors.grey[350],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          category,
          style: const TextStyle(fontFamily: 'Bangers', fontSize: 17).copyWith(
            color: selectedCategory == category ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
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
            "HOMEPAGE",
            style: TextStyle(
                fontSize: 18, fontFamily: 'Bangers', color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        // Wrap the entire content in SingleChildScrollView
        child: Container(
          margin: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("WELCOME, $nameks.",
                      style:
                          const TextStyle(fontFamily: 'Oswald', fontSize: 20)),
                  ClipOval(
                    child: Container(
                      color: Colors
                          .black, // Background color for the circular image
                      child: Image.asset(
                        "images/12.jpg", // Adjust the path if necessary
                        width: 40, // Set the width of the circular image
                        height: 40, // Set the height of the circular image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              const Text("EASE ESTATE",
                  style: TextStyle(fontFamily: 'Bangers', fontSize: 18)),
              const Text("Rent a Room",
                  style: TextStyle(fontFamily: 'Oswald', fontSize: 18)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildCategoryButton("Standard"),
                  buildCategoryButton("Deluxe"),
                  buildCategoryButton("Suites"),
                  buildCategoryButton("Specialty"),
                ],
              ),
              //const SizedBox(height: 30.0),
              //SizedBox(height: 250, child: allItems()),
              const SizedBox(height: 30.0),
              SizedBox(
                height: 400,
                child: allItemsVertically(),
              ), // Adjust height as needed
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}
