import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class EditRoomScreen extends StatefulWidget {
  final String collectionName;
  final String docID;
  final String images;
  final String title;
  final String description;
  final String address;
  final String price;
  final String maxGuests;
  final String status;

  const EditRoomScreen({
    super.key,
    required this.collectionName,
    required this.docID,
    required this.images,
    required this.title,
    required this.description,
    required this.address,
    required this.price,
    required this.maxGuests,
    required this.status,
  });

  @override
  _EditRoomScreenState createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final maxGuestsController = TextEditingController();
  String? status;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage; // For mobile
  Uint8List? selectedImageBytes; // For web image storage

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with the current room details
    titleController.text = widget.title;
    descController.text = widget.description;
    addressController.text = widget.address;
    priceController.text = widget.price;
    maxGuestsController.text = widget.maxGuests;
    status = widget.status; // Set the initial status
  }

  Future<void> getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        selectedImageBytes = null;
      });

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          selectedImage = null;
          selectedImageBytes = bytes;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No image selected"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateRoom() async {
    Map<String, dynamic> updatedData = {
      "Title": titleController.text,
      "Description": descController.text,
      "Address": addressController.text,
      "Price": priceController.text,
      "MaxGuests": maxGuestsController.text,
      "Status": status,
    };

    if (selectedImage != null || selectedImageBytes != null) {
      String? downloadUrl;
      final firebaseStorageRef =
          FirebaseStorage.instance.ref().child("Image").child(widget.docID);
      try {
        // Upload the new image and get the download URL
        if (selectedImage != null) {
          // Mobile case
          final task = firebaseStorageRef.putFile(selectedImage!);
          downloadUrl = await (await task).ref.getDownloadURL();
        } else {
          // Web case
          final uploadTask = firebaseStorageRef.putData(selectedImageBytes!);
          downloadUrl = await (await uploadTask).ref.getDownloadURL();
        }

        // Update the image URL in the data
        updatedData["Image"] = downloadUrl;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload image: $e")));
        return;
      }
    } else {
      // If no new image is selected, retain the old image URL
      updatedData["Image"] = widget.images;
    }

    try {
      // Update the document in Firestore
      await DatabaseMethods()
          .updateRoomItem(widget.collectionName, widget.docID, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Room updated successfully.")));
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error updating room: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ), // Use any icon you prefer
          onPressed: () {
            Navigator.pop(context); // Pop the current screen
          },
        ),
        actions: [
          TextButton(
            onPressed: _updateRoom,
            child: const Row(
              children: [
                Icon(Icons.save, color: Colors.white), // Save icon
                // Space between icon and text
                Text(
                  "SAVE",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Bangers',
                      color: Colors.white), // Save text
                ),
              ],
            ),
          ),
        ],
        title: const Center(
          child: Text(
            "Edit Room",
            style: TextStyle(
                fontSize: 18, fontFamily: 'Bangers', color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: maxGuestsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Guests',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Status"),
            DropdownButton<String>(
              value: status,
              items: <String>['Available', 'Not Available'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  status = newValue!;
                });
              },
            ),
            const SizedBox(height: 10),
            const Text("Select New Image"),
            GestureDetector(
              onTap: getImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: selectedImageBytes == null && selectedImage == null
                    ? const Icon(Icons.camera_alt_outlined)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb
                            ? Image.memory(selectedImageBytes!,
                                fit: BoxFit.cover) // For web
                            : Image.file(selectedImage!,
                                fit: BoxFit.cover), // For mobile
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
