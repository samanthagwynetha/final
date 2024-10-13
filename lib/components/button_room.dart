import 'package:flutter/material.dart';

class ButtonRoom extends StatelessWidget {
  final Function onPressed;

  const ButtonRoom({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Center(
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            width: 150,
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(
              child: Text(
                "Add",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
