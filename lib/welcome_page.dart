import 'package:flutter/material.dart';

import 'home_page.dart';

class WelcomePage extends StatefulWidget {
  final String user;

  const WelcomePage({super.key, required this.user});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
        return true;
      },
      child: Scaffold(
        body: Center(
          child: Container(
            child: Text(
              'Welcome ${widget.user}',
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      ),
    );
  }
}
