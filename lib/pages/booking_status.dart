import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/widget/support_widget.dart';
import 'package:intl/intl.dart';

class BookingStatusPage extends StatefulWidget {
  const BookingStatusPage({super.key});

  @override
  _BookingStatusPageState createState() => _BookingStatusPageState();
}

class _BookingStatusPageState extends State<BookingStatusPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> bookingStream;

  @override
  void initState() {
    super.initState();
    fetchBookingStatus();
  }

  void fetchBookingStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not logged in.");
      return;
    }

    String userId = user.uid;
    print("Current User ID: $userId");

    bookingStream = FirebaseFirestore.instance
        .collection('Bookings')
        .where('UserID', isEqualTo: userId)
        .snapshots();
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(bookingId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking canceled successfully.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to cancel booking: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Booking Status',
            style: TextStyle(
                fontSize: 18, fontFamily: 'Bangers', color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color.fromARGB(255, 197, 185, 185),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: bookingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "No bookings found.",
                  style: TextStyle(fontSize: 18, fontFamily: 'ProtestStrike'),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> booking =
                  snapshot.data!.docs[index];
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          "Booking ID: ${booking['BookingID']}",
                          style: Appwidget.oswald(),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Check-in: ${DateFormat('yyyy-MM-dd').format(booking['CheckInDate'].toDate())}",
                                  style: Appwidget.oswald()),
                              Text(
                                  "Check-out: ${DateFormat('yyyy-MM-dd').format(booking['CheckOutDate'].toDate())}",
                                  style: Appwidget.oswald()),
                              Text(
                                  "Total Price: ₱${booking['TotalPrice'].toStringAsFixed(2)}",
                                  style: Appwidget.oswald()),
                              Text("Status: ${booking['Status']}",
                                  style: Appwidget.oswald()),
                            ],
                          ),
                        ),
                      ),
                      if (booking['Status'] == 'Pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _cancelBooking(booking.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text("Cancel", style: Appwidget.bangers()),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
