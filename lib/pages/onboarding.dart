import 'package:flutter/material.dart';
import 'package:homehunt/auth/auth.dart';
import 'package:homehunt/widget/content_model.dart';
import 'package:homehunt/widget/support_widget.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
                  child: SingleChildScrollView(
                    // Make the content scrollable
                    child: Column(
                      children: [
                        Container(
                          width: size.width,
                          height: size.height * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            image: DecorationImage(
                              image: AssetImage(contents[i].image), 
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      
                        const SizedBox(height: 40.0),
                        Text(
                          contents[i].title,
                          style: Appwidget.HeadlineTextfieldstyle(),
                          textAlign: TextAlign.center, // Center the title
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          contents[i].description,
                          style: const TextStyle(
                              fontSize: 18, fontFamily: 'Oswald'),
                          textAlign: TextAlign.center, 
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              contents.length,
              (index) => buildDot(index, context),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (currentIndex == contents.length - 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              } else {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.bounceIn,
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                 color: Color.fromARGB(255, 8, 8, 8),
                borderRadius: BorderRadius.circular(20),
              ),
              height: 60,
              margin: const EdgeInsets.all(40),
              width: double.infinity,
              child: Center(
                child: Text(
                  currentIndex == contents.length - 1 ? "Start" : "Next",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10.0,
      width: currentIndex == index ? 18 : 7,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.black38,
      ),
    );
  }
}
