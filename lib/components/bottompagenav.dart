import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/pages/booking_status.dart';
import 'package:homehunt/pages/home.dart';
import 'package:homehunt/pages/profile.dart';

class Bottompagenav extends StatefulWidget {
  const Bottompagenav({super.key});

  @override
  State<Bottompagenav> createState() => _BottompagenavState();
}

class _BottompagenavState extends State<Bottompagenav> {
  late List<Widget> pages;
  late Home homepage;
  late BookingStatusPage bookingStatusPage;
  late Profile profile;
  int currenttabindex = 0;

  @override
  void initState() {
    super.initState();
    homepage = const Home();

    bookingStatusPage = const BookingStatusPage();
    profile = const Profile();

    pages = [homepage, bookingStatusPage, profile];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.transparent,
        color: const Color.fromARGB(255, 0, 0, 0),
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currenttabindex = index;
          });
        },
        items: const [
          Icon(Icons.home_outlined, color: Colors.white),
          Icon(Icons.book_online_outlined, color: Colors.white),
          Icon(Icons.person_2_outlined, color: Colors.white),
        ],
      ),
      body: pages[currenttabindex],
    );
  }
}
