import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image/image.dart' as imglib;

import 'camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isProccesing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isProccesing,
      progressIndicator: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Proccesing...'),
              SpinKitThreeBounce(
                color: Colors.blue,
              )
            ],
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Face Recognition By Kvn'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FaceScanScreen(
                              login: false,
                            ),
                          ));
                    },
                    child: const Text('REGISTER')),
                ElevatedButton(
                    onPressed: () async {
                      // await loginPressed();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FaceScanScreen(
                              login: true,
                            ),
                          ));
                    },
                    child: const Text('LOGIN')),
                // ElevatedButton(
                //     onPressed: () async {}, child: Text('Clear Users List')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
