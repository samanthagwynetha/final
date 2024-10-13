import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/admin/add_room.dart';
import 'package:homehunt/admin/edit_room.dart';
import 'package:homehunt/pages/home.dart';
import 'package:homehunt/services/database.dart';
import 'package:homehunt/widget/support_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Stream<QuerySnapshot>? roomItemStream;
  String selectedCategory = "Standard"; // Default category

  @override
  void initState() {
    super.initState();
    _loadRoomItems();
  }

  void _loadRoomItems() async {
    roomItemStream = await DatabaseMethods().getRoomItem(selectedCategory);
    setState(() {}); // Refresh UI
  }

  Widget _buildRoomItemList() {
    return StreamBuilder<QuerySnapshot>(
      stream: roomItemStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text(
            "No items found.",
            style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike'),
          ));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildRoomItemCard(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildRoomItemCard(DocumentSnapshot ds) {
    return Container(
      margin: const EdgeInsets.only(right: 10.0, bottom: 15),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(5),
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
                    Text(ds["Title"], style: Appwidget.proteststrike()),
                    const SizedBox(height: 10),
                    Text("₱${ds["Price"]}", style: Appwidget.proteststrike()),
                    const SizedBox(height: 10),
                    Text("MaxGuests:${ds["MaxGuests"]}",
                        style: Appwidget.proteststrike()),
                  ],
                ),
              ),
              _buildEditIcon(ds),
              _buildDeleteIcon(ds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditIcon(DocumentSnapshot ds) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        String collectionName =
            selectedCategory; // Use selected category directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditRoomScreen(
              collectionName: collectionName,
              docID: ds.id,
              images: ds["Image"],
              title: ds["Title"],
              description: ds["Description"],
              address: ds["Address"],
              price: (ds["Price"]),
              maxGuests: (ds["MaxGuests"]),
              status: ds["Status"],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteIcon(DocumentSnapshot ds) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () async {
        bool confirm = await _showDeleteConfirmationDialog();
        if (confirm) {
          await DatabaseMethods().deleteRoomItem(selectedCategory, ds.id);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Room item deleted successfully.",
            style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike'),
          )));
          _loadRoomItems(); // Refresh the list after deletion
        }
      },
    );
  }

  Future<bool> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Room Item",
            style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike'),
          ),
          content: const Text("Are you sure you want to delete this item?",
              style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike')),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel",
                    style: TextStyle(fontSize: 18, fontFamily: 'Bangers'))),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete",
                    style: TextStyle(fontSize: 18, fontFamily: 'Bangers'))),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  // Method to create category buttons
  Widget _buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category; // Update selected category
          _loadRoomItems(); // Fetch new data for the selected category
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
          style: const TextStyle(fontFamily: 'Bangers', fontSize: 20).copyWith(
            color: selectedCategory == category ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            "HOMEPAGE",
            style: TextStyle(
                fontSize: 18, fontFamily: 'Bangers', color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Admin Dashboard",
                    style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Bangers',
                        color: Colors.black)),
                ClipOval(
                  child: Container(
                    color:
                        Colors.black, // Background color for the circular image
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton("Standard"),
                _buildCategoryButton("Deluxe"),
                _buildCategoryButton("Suites"),
                _buildCategoryButton("Specialty"),
              ],
            ),
            const SizedBox(height: 30.0),
            Expanded(
                child:
                    _buildRoomItemList()), // Display vertical list of room items
            const SizedBox(height: 30.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const AddRoom())); // Navigate to AddRoom
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
