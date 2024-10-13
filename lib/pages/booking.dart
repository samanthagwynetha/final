import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:flutter/foundation.dart'; // For kIsWeb

class BookingPage extends StatefulWidget {
  final String price; // Kept as String to accept user input

  BookingPage({required this.price});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  XFile? imageFile;
  Uint8List? imageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? (checkInDate ?? DateTime.now()) : (checkOutDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != (isCheckIn ? checkInDate : checkOutDate)) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _uploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile; // Keep for mobile
        imageBytes = null; // Clear web bytes for mobile
      });

      // Convert to Uint8List for web image handling
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          imageFile = null; // Clear the file for web usage
          imageBytes = bytes; // Store the bytes for display
        });
      }
    }
  }

  double _calculateTotalPrice() {
    // Convert price from string to double
    double pricePerNight = double.tryParse(widget.price) ?? 0.0;

    if (checkInDate != null && checkOutDate != null) {
      int totalDays = checkOutDate!.difference(checkInDate!).inDays;
      return totalDays > 0 ? totalDays * pricePerNight : 0.0;
    }
    return 0.0;
  }

  Future<String?> _uploadImageToFirebase() async {
    if (imageFile != null) {
      File file = File(imageFile!.path);
      try {
        // Upload the file to Firebase Storage
        String fileName = 'uploads/${DateTime.now().millisecondsSinceEpoch}_${imageFile!.name}';
        TaskSnapshot snapshot = await FirebaseStorage.instance.ref(fileName).putFile(file);
        
        // Get the download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        print("Error uploading image: $e");
      }
    } else if (imageBytes != null) {
      try {
        // Upload the image bytes for web
        String fileName = 'uploads/${DateTime.now().millisecondsSinceEpoch}.png';
        Reference ref = FirebaseStorage.instance.ref(fileName);
        UploadTask uploadTask = ref.putData(imageBytes!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return null;
  }

  Future<void> _confirmBooking() async {
    if (checkInDate != null && checkOutDate != null) {
      // Calculate total price
      double totalPrice = _calculateTotalPrice();
      
      // Get the current user's ID
      User? user = FirebaseAuth.instance.currentUser;
      String? uid = user?.uid;

      // Generate a unique BookingID
      String bookingId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload image and get its download URL
      String? imagePath = await _uploadImageToFirebase();

      // Prepare booking data
      Map<String, dynamic> bookingData = {
        'BookingID': bookingId,
        'UserID': uid,
        'CheckInDate': checkInDate,
        'CheckOutDate': checkOutDate,
        'TotalPrice': totalPrice,
        'Status': 'Pending',
        'ImagePath': imagePath, // Use the uploaded image URL
      };

      try {
        // Save booking data to Firestore
        await FirebaseFirestore.instance.collection('Bookings').doc(bookingId).set(bookingData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Confirmed! Total Price: ₱${totalPrice.toStringAsFixed(2)}")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to confirm booking: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book a Room",
          style: TextStyle(
              fontSize: 18, fontFamily: 'Bangers', color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body:Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Check-in Date",
                style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike')),
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  checkInDate == null
                      ? 'Select date'
                      : DateFormat('yyyy-MM-dd').format(checkInDate!),
                  style: const TextStyle(
                      fontSize: 16, fontFamily: 'ProtestStrike'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Check-out Date",
                style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike')),
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  checkOutDate == null
                      ? 'Select date'
                      : DateFormat('yyyy-MM-dd').format(checkOutDate!),
                  style: const TextStyle(
                      fontSize: 18, fontFamily: 'ProtestStrike'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Upload Image (VALID ID)",
                style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike')),
            GestureDetector(
              onTap: _uploadImage,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: imageFile == null && imageBytes == null
                    ? const Text('Tap to upload an image',
                        style: TextStyle(
                            fontSize: 16, fontFamily: 'ProtestStrike'))
                    : kIsWeb
                        ? Image.memory(imageBytes!,
                            width: 100, height: 100) // For web
                        : Image.file(File(imageFile!.path),
                            width: 100, height: 100), // For mobile
              ),
            ),
            const SizedBox(height: 20),
            Text("Total Price: ₱${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontFamily: 'Oswald')),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color.fromARGB(255, 8, 8, 8),
                  elevation: 7,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
                ),
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(
                      fontSize: 20, fontFamily: 'Bangers', color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
