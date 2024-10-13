import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/services/database.dart';
import 'package:homehunt/widget/support_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class AddRoom extends StatefulWidget {
  const AddRoom({super.key});

  @override
  State<AddRoom> createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  final List<String> roomItems = ['Standard', 'Deluxe', 'Suites', 'Specialty'];
  String? category, status;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final maxGuestsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  Uint8List? selectedImageBytes;
  bool isLoading = false;

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
            content: Text("No image selected",
                style: TextStyle(fontSize: 20, fontFamily: 'ProtestStrike')),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> uploadItem() async {
    if (selectedImage != null ||
        selectedImageBytes != null &&
            titleController.text.isNotEmpty &&
            descController.text.isNotEmpty &&
            addressController.text.isNotEmpty &&
            priceController.text.isNotEmpty &&
            maxGuestsController.text.isNotEmpty &&
            status != null) {
      setState(() {
        isLoading = true;
      });

      try {
        final addId = randomAlphaNumeric(10);
        final firebaseStorageRef =
            FirebaseStorage.instance.ref().child("Image").child(addId);

        // Upload the image
        String downloadUrl;
        if (selectedImage != null) {
          // Mobile case
          final task = firebaseStorageRef.putFile(selectedImage!);
          downloadUrl = await (await task).ref.getDownloadURL();
        } else {
          // Web case
          final byteData = selectedImageBytes!;
          final uploadTask = firebaseStorageRef.putData(byteData);
          downloadUrl = await (await uploadTask).ref.getDownloadURL();
        }

        // Add room item with details
        final addItem = {
          "Image": downloadUrl,
          "Title": titleController.text,
          "Description": descController.text,
          "Address": addressController.text,
          "Price": priceController.text,
          "MaxGuests": maxGuestsController.text,
          "Status": status,
        };

        await DatabaseMethods().addRoomItem(addItem, category!).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text("Room Item has been added Successfully",
                  style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike')),
            ),
          );
          Navigator.pop(context);
        });
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to upload room item: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill in all fields and select an image",
                style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike')),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Appwidget.proteststrike()),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFececf8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter $label",
              hintStyle: Appwidget.proteststrike(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDropdown(String label, List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Appwidget.proteststrike()),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFececf8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'ProtestStrike',
                                color: Colors.black)),
                      ))
                  .toList(),
              onChanged: onChanged,
              dropdownColor: Colors.white,
              hint: Text("Select $label"),
              iconSize: 36,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              value: selectedValue,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_outlined,
              color: Color(0xFF373866)),
        ),
        centerTitle: true,
        title: Text("Add Item", style: Appwidget.bangers()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Upload the Item Picture", style: Appwidget.bangers()),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: getImage,
                      child: Center(
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: selectedImageBytes == null &&
                                    selectedImage == null
                                ? const Icon(Icons.camera_alt_outlined,
                                    color: Colors.black)
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: kIsWeb
                                        ? Image.memory(selectedImageBytes!,
                                            fit: BoxFit.cover) // For web
                                        : Image.file(selectedImage!,
                                            fit: BoxFit.cover), // For mobile
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildTextField("Title", titleController),
                    const SizedBox(height: 30),
                    buildTextField("Description", descController, maxLines: 6),
                    const SizedBox(height: 30),
                    buildTextField("Address", addressController),
                    const SizedBox(height: 30),
                    buildTextField("Price", priceController),
                    const SizedBox(height: 30),
                    buildTextField("Maximum Guests", maxGuestsController),
                    const SizedBox(height: 20),
                    buildDropdown("Select Category", roomItems, category,
                        (value) => setState(() => category = value)),
                    const SizedBox(height: 30),
                    buildDropdown(
                        "Select Status",
                        ["Available", "Not Available"],
                        status,
                        (value) => setState(() => status = value)),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: uploadItem,
                      child: Center(
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Add",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontFamily: 'Bangers'),
                              ),
                            ),
                          ),
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
