import 'package:flutter/material.dart';
import 'package:homehunt/pages/booking.dart';
import 'package:homehunt/widget/support_widget.dart';

class Details extends StatefulWidget {
  final String title, description, address, price, maxguests, images, status;

  Details({
    super.key,
    required this.title,
    required this.description,
    required this.address,
    required this.price,
    required this.maxguests,
    required this.images,
    required this.status,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(
              top: 30.0, left: 20.0, right: 20.0, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios_new_outlined,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              Image.network(
                widget.images,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 15.0),
              Text(widget.title, style: Appwidget.bangers()),
              const SizedBox(height: 15.0),
              Text(widget.description, style: Appwidget.oswald()),
              const SizedBox(height: 15.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
  children: [
    const Icon(Icons.location_on, color: Colors.red),
    const SizedBox(width: 6),
    Expanded(
      child: Text(
        widget.address,
        style: Appwidget.oswald(),
        overflow: TextOverflow.ellipsis, // Truncates with "..."
        maxLines: 1, // Ensures it stays on one line
      ),
    ),
  ],
),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.group, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(widget.maxguests, style: Appwidget.oswald()),
                    ],
                  ),
                  const SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Price",
                                style: Appwidget.proteststrike()),
                            Text("₱ ${widget.price}",
                                style: Appwidget.proteststrike()),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10)),
                          child: GestureDetector(
                            onTap: () {
                              // Log the price for debugging
                              print("Price before parsing: ${widget.price}");

                              // Remove commas and ensure the price is a valid number string
                              final priceString = widget.price.replaceAll(',', '').trim();
                              final price = double.tryParse(priceString);
                              
                              if (price != null) {
                                // Pass price as String
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingPage(price: priceString), // Pass as string
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Invalid price format: $priceString"),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text("BOOK NOW!",
                                    style: TextStyle(color: Colors.white)),
                                const SizedBox(width: 30.0),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.book),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
